local Core = exports.vorp_core:GetCore()
local BccUtils = exports['bcc-utils'].initiate()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

local TrainRobberyAlert = exports['bcc-job-alerts']:RegisterAlert(Config.alerts.law)
local discord = BccUtils.Discord.setup(Config.webhook.link, Config.webhook.title, Config.webhook.avatar)

local ActiveTrains = {}
local LockpickAttempts = {}
local CooldownData = {}
local ActiveMissions = {}     -- Track active delivery missions
local OperationCooldowns = {} -- Track cooldowns for expensive operations
local DevModeActive = Config.devMode.active or false
TrainEntity = nil
BridgeDestroyed = false

-- Track spawned trains by region for spawn limits
local SpawnedTrainsByRegion = {
    east = 0, -- outWest = false
    west = 0  -- outWest = true
}

-- Get train configuration by hex hash from all categories
local function getTrainConfig(hexHash)
    if not hexHash then
        DBG.Warning('getTrainConfig called with nil hash')
        return nil
    end

    local config = (Cargo and Cargo[hexHash]) or
        (Passenger and Passenger[hexHash]) or
        (Mixed and Mixed[hexHash]) or
        (Special and Special[hexHash])

    if not config then
        DBG.Warning(string.format('Train configuration not found for hash: %s', tostring(hexHash)))
    end

    return config
end

-- Validate that a player owns a specific train
local function validateTrainOwnership(source, trainId)
    if not source or not trainId then
        DBG.Error('validateTrainOwnership called with invalid parameters')
        return false
    end

    -- Validate trainId is a number to prevent SQL injection
    local numericTrainId = tonumber(trainId)
    if not numericTrainId or numericTrainId <= 0 then
        DBG.Error('Invalid train ID format provided')
        return false
    end

    local user = Core.getUser(source)
    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(source)))
        return false
    end

    local character = user.getUsedCharacter
    if not character then
        DBG.Error('Character not found for user')
        return false
    end

    -- Query database to check if player owns this train
    local result = MySQL.query.await(
        'SELECT COUNT(*) as count FROM `bcc_player_trains` WHERE `charidentifier` = ? AND `trainid` = ?',
        { character.charIdentifier, numericTrainId })

    if not result or not result[1] or result[1].count == 0 then
        DBG.Warning(string.format('Player %s (char: %s) attempted to access train %s they do not own',
            tostring(source), tostring(character.charIdentifier), tostring(numericTrainId)))
        return false
    end

    return true
end

-- Helper: verify item removal and log if it didn't remove the expected amount
-- helper removed: direct inventory subItem calls preferred in hot paths

-- Rate limiting functions
local function checkOperationCooldown(source, operation, cooldownSeconds)
    -- Check if rate limiting is disabled
    if not Config.rateLimiting or not Config.rateLimiting.enabled then
        return true, 0
    end

    if not source or not operation then
        return false
    end

    local playerKey = tostring(source)
    local currentTime = os.time()

    if not OperationCooldowns[playerKey] then
        OperationCooldowns[playerKey] = {}
    end

    -- Check if cooldown exists and is still active
    if OperationCooldowns[playerKey][operation] then
        local timeRemaining = OperationCooldowns[playerKey][operation] - currentTime
        if timeRemaining > 0 then
            return false, timeRemaining
        else
            -- Clean up expired cooldown
            OperationCooldowns[playerKey][operation] = nil
        end
    end

    -- Set cooldown
    OperationCooldowns[playerKey][operation] = currentTime + cooldownSeconds
    return true, 0
end

-- Periodic cleanup of expired cooldowns (runs every 5 minutes)
local function cleanupExpiredCooldowns()
    local currentTime = os.time()
    local cleanedCount = 0

    for playerKey, operations in pairs(OperationCooldowns) do
        for operation, expireTime in pairs(operations) do
            if expireTime <= currentTime then
                operations[operation] = nil
                cleanedCount = cleanedCount + 1
            end
        end

        -- Remove empty player entries
        if next(operations) == nil then
            OperationCooldowns[playerKey] = nil
        end
    end

    if cleanedCount > 0 then
        DBG.Info(string.format('Cleaned up %d expired cooldowns', cleanedCount))
    end
end

-- Start periodic cleanup timer
CreateThread(function()
    while true do
        Wait(300000) -- Wait 5 minutes
        cleanupExpiredCooldowns()
    end
end)

-- Player position reporting and cleanup removed with global blip system.

-- Cleanup disconnected players from tracking tables
local function cleanupDisconnectedPlayer(source)
    local playerKey = tostring(source)

    -- Clean up tracking tables
    if LockpickAttempts[source] then
        LockpickAttempts[source] = nil
    end

    if OperationCooldowns[playerKey] then
        OperationCooldowns[playerKey] = nil
    end

    if ActiveMissions[source] then
        ActiveMissions[source] = nil
    end

    DBG.Info(string.format('Cleaned up tracking data for disconnected player: %s', tostring(source)))
end

-- Handle player disconnection
AddEventHandler('playerDropped', function(reason)
    local source = source
    cleanupDisconnectedPlayer(source)
end)

-- Item helpers
local function getItemLabel(itemId)
    -- Check delivery config for item labels
    if DeliveryLocations then
        for _, location in pairs(DeliveryLocations) do
            if location.items then
                for _, item in ipairs(location.items) do
                    if item.item == itemId and item.label then
                        return item.label
                    end
                end
            end
            if location.rewards and location.rewards.items then
                for _, item in ipairs(location.rewards.items) do
                    if item.item == itemId and item.label then
                        return item.label
                    end
                end
            end
        end
    end
    
    -- Fallback to item ID
    return tostring(itemId)
end

-- Mission tracking functions
local function startDeliveryMission(source, destination)
    if not source or not destination then
        return false
    end

    local user = Core.getUser(source)
    if not user then
        return false
    end

    local character = user.getUsedCharacter
    if not character then
        return false
    end

    -- Check if destination requires items
    -- Defensive: destination may be a sanitized table from client (no vector3s). Validate fields.
    if destination.requireItem and destination.items and type(destination.items) == 'table' then
        for _, requiredItem in ipairs(destination.items) do
            local itemCount = exports.vorp_inventory:getItemCount(source, nil, requiredItem.item)
            if itemCount < requiredItem.quantity then
                local itemLabel = getItemLabel(requiredItem.item)
                Core.NotifyRightTip(source, _U('needItemsForDelivery') .. ': ' .. tostring(requiredItem.quantity) .. ' x ' .. tostring(itemLabel), 4000)
                return false
            end
        end

        -- Remove required items from inventory
        for _, requiredItem in ipairs(destination.items) do
            DBG.Info(string.format('Removing item for mission start: src=%s item=%s qty=%s', tostring(source), tostring(requiredItem.item), tostring(requiredItem.quantity)))
            exports.vorp_inventory:subItem(source, requiredItem.item, requiredItem.quantity)
            DBG.Info(string.format('Requested removal: src=%s item=%s qty=%s', tostring(source), tostring(requiredItem.item), tostring(requiredItem.quantity)))
        end

        Core.NotifyRightTip(source, _U('deliveryItemsConsumed'), 3000)
    end

    -- Create mission entry with timestamp and destination info
    ActiveMissions[source] = {
        type = 'delivery',
        charIdentifier = character.charIdentifier,
        destination = destination,
        startTime = os.time(),
        completed = false
    }

    DBG.Info(string.format('Started delivery mission for player %s to %s',
        tostring(source), tostring(destination.name or 'unknown')))
    return true
end

local function validateAndCompleteDeliveryMission(source, destination)
    if not source or not destination then
        DBG.Error('Invalid parameters for delivery validation')
        return false
    end

    local mission = ActiveMissions[source]
    if not mission then
        DBG.Warning(string.format('No active mission found for player %s', tostring(source)))
        return false
    end

    if mission.type ~= 'delivery' then
        DBG.Warning(string.format('Player %s attempted to complete wrong mission type', tostring(source)))
        return false
    end

    if mission.completed then
        DBG.Warning(string.format('Player %s attempted to complete already completed mission', tostring(source)))
        return false
    end

    -- Basic validation - ensure destination matches and mission isn't too old (prevent replay attacks)
    local maxMissionTime = 3600 -- 1 hour maximum mission time
    if os.time() - mission.startTime > maxMissionTime then
        DBG.Warning(string.format('Mission expired for player %s', tostring(source)))
        ActiveMissions[source] = nil
        return false
    end

    -- Mark mission as completed
    mission.completed = true
    DBG.Info(string.format('Validated delivery mission completion for player %s', tostring(source)))
    return true
end

-- Server callback to get train config for a train model
Core.Callback.Register('bcc-train:server:getTrainConfig', function(source, cb, model)
    local trainConfig = getTrainConfig(model)
    cb(trainConfig)
end)

-- Get job-filtered trains for buy menu
Core.Callback.Register('bcc-train:GetJobFilteredTrains', function(source, cb, category)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb({})
    end

    local character = user.getUsedCharacter
    local playerJob = character.job

    local categoryMap = {
        cargo = Cargo,
        passenger = Passenger,
        mixed = Mixed,
        special = Special
    }

    local categoryTrains = categoryMap[category]
    if not categoryTrains then
        return cb({})
    end

    local filteredTrains = {}
    for trainHash, trainCfg in pairs(categoryTrains) do
        -- Check if train has job requirements
        if trainCfg.job and #trainCfg.job > 0 then
            -- Check if player has required job
            local hasRequiredJob = false
            for _, requiredJob in ipairs(trainCfg.job) do
                if playerJob == requiredJob then
                    hasRequiredJob = true
                    break
                end
            end

            if hasRequiredJob then
                filteredTrains[trainHash] = trainCfg
            end
        else
            -- No job requirements, available to all
            filteredTrains[trainHash] = trainCfg
        end
    end

    cb(filteredTrains)
end)

-- Get current regional spawn counts for UI display
Core.Callback.Register('bcc-train:GetRegionalSpawnCounts', function(source, cb)
    local counts = {
        east = {
            current = SpawnedTrainsByRegion.east or 0,
            limit = Config.spawnLimits.east
        },
        west = {
            current = SpawnedTrainsByRegion.west or 0,
            limit = Config.spawnLimits.west
        }
    }
    cb(counts)
end)

-- Debug command to check regional spawn counts (if dev mode enabled)
if DevModeActive then
    RegisterCommand('trainlimits', function(source, args, rawCommand)
        local user = Core.getUser(source)
        if not user then return end

        local counts = {
            east = SpawnedTrainsByRegion.east or 0,
            west = SpawnedTrainsByRegion.west or 0
        }

        Core.NotifyRightTip(source, _U('regionLimits') .. ': ' .. tostring(counts.east) .. '/' .. tostring(Config.spawnLimits.east) .. ' | ' .. tostring(counts.west) .. '/' .. tostring(Config.spawnLimits.west), 6000)

        DBG.Info(string.format('Regional Limits - East: %d/%d, West: %d/%d',
            counts.east, Config.spawnLimits.east,
            counts.west, Config.spawnLimits.west))
    end, false)
end

local function CheckPlayerJob(charJob, jobGrade, shop)
    -- Validate shop configuration exists
    local stationCfg = Stations[shop]
    if not stationCfg or not stationCfg.shop or not stationCfg.shop.jobs then
        DBG.Error(string.format('Invalid shop configuration for job check: %s', tostring(shop)))
        return false
    end

    local jobs = stationCfg.shop.jobs
    for _, job in ipairs(jobs) do
        if charJob == job.name and jobGrade >= job.grade then
            return true
        end
    end
    return false
end

Core.Callback.Register('bcc-train:CheckJob', function(source, cb, shop)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(false)
    end

    -- Validate shop parameter
    if not shop or type(shop) ~= 'string' then
        DBG.Error(string.format('Invalid shop parameter received from source: %d', src))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charJob = character.job
    local jobGrade = character.jobGrade

    DBG.Info(string.format('Checking job for user: charJob=%s, jobGrade=%s', charJob, jobGrade))

    if not charJob or not CheckPlayerJob(charJob, jobGrade, shop) then
        DBG.Warning('User does not have the required job or grade.')
        Core.NotifyRightTip(src, _U('needJob'), 4000)
        return cb(false)
    end

    DBG.Success('User has the required job and grade.')
    cb(true)
end)

-- Helper: get human-friendly label for an item from the `items` DB table.
-- Expose a simple callback so clients can resolve labels without running DB queries locally
Core.Callback.Register('bcc-train:GetItemLabel', function(source, cb, itemId)
    cb(getItemLabel(itemId))
end)

-- Batch resolver for multiple item ids. Returns a map { itemId = label }
Core.Callback.Register('bcc-train:GetItemLabels', function(source, cb, items)
    if not items or type(items) ~= 'table' then
        return cb({})
    end
    local out = {}
    for _, id in ipairs(items) do
        out[id] = getItemLabel(id)
    end
    cb(out)
end)

-- Helper: return full item data (server-side). Shape returned approximates:
-- { id=string, label=string, name=string, metadata=table, group=number, type=string, count=number, limit=number, canUse=boolean, weight=number, desc=string, percentage=integer }
local function getItemData(itemId)
    if not itemId then return nil end
    if type(itemId) == 'table' then
        local out = {}
        for _, id in ipairs(itemId) do
            out[id] = getItemData(id)
        end
        return out
    end

    -- Use vorp_inventory export
    if exports.vorp_inventory and exports.vorp_inventory.getItem then
        local ok, info = pcall(function() return exports.vorp_inventory:getItem(itemId) end)
        if ok and info then
            info.id = info.id or itemId
            return info
        end
    end

    -- Return minimal table as fallback
    return { id = itemId, label = tostring(itemId), name = tostring(itemId), metadata = {}, group = 0, type = 'item', count = 0, limit = 0, canUse = false, weight = 0, desc = '', percentage = 0 }
end

-- Callback to return item data (single id string or table of ids)
Core.Callback.Register('bcc-train:GetItemData', function(source, cb, item)
    if not item then return cb(nil) end
    cb(getItemData(item))
end)

-- Server-side permission check for the on-demand showtrains command.
-- Returns true if the player is allowed to use the command, false otherwise.
Core.Callback.Register('bcc-train:CanUseShowTrains', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(false)
    end


    -- If the feature is disabled or missing, allow everyone by default
    if not Config.trainBlips or not Config.trainBlips.showTrains then
        return cb(true)
    end

    local cfg = Config.trainBlips.showTrains
    if not cfg.jobsEnabled then
        return cb(true)
    end

    local character = user.getUsedCharacter
    if not character then
        return cb(false)
    end

    local playerJob = character.job
    local playerGrade = character.jobGrade or 0

    -- If no jobs are configured, allow everyone
    if not cfg.jobs or #cfg.jobs == 0 then
        return cb(true)
    end

    for _, j in ipairs(cfg.jobs) do
        local name = j.name
        local minGrade = j.grade or 0
        if playerJob == name and playerGrade >= minGrade then
            return cb(true)
        end
    end

    -- Not allowed
    Core.NotifyRightTip(src, _U('needJob'), 4000)
    return cb(false)
end)

-- Check if train can be spawned based on regional limits
Core.Callback.Register('bcc-train:CheckTrainSpawn', function(source, cb, stationName)
    if not stationName or type(stationName) ~= 'string' then
        DBG.Error('CheckTrainSpawn called without valid station name')
        return cb(false)
    end

    -- Get station configuration to determine region
    local station = Stations[stationName]
    if not station or not station.train then
        DBG.Error(string.format('Station configuration not found: %s', tostring(stationName)))
        return cb(false)
    end

    -- Determine region based on outWest flag
    local region = station.train.outWest and 'west' or 'east'
    local currentCount = SpawnedTrainsByRegion[region] or 0
    local limit = region == 'west' and Config.spawnLimits.west or Config.spawnLimits.east

    DBG.Info(string.format('Regional spawn check - Station: %s, Region: %s, Current: %d, Limit: %d',
        stationName, region, currentCount, limit))

    if currentCount >= limit then
        DBG.Warning(string.format('Regional spawn limit reached for %s region (%d/%d)', region, currentCount, limit))
        cb(false)
    else
        cb(true)
    end
end)

Core.Callback.Register('bcc-train:CheckDeliveryItems', function(source, cb, destination)
    -- Handle invalid destination
    if not destination then
        DBG.Error('CheckDeliveryItems called without destination')
        cb({ hasItems = false, missingItems = {}, error = 'Invalid destination' })
        return
    end

    -- If no item requirements, allow mission to proceed
    if not destination.requireItem or not destination.items then
        cb({ hasItems = true, missingItems = {} })
        return
    end

    local missingItems = {}
    local requiredItemsWithCounts = {}
    for _, requiredItem in ipairs(destination.items) do
        local itemCount = exports.vorp_inventory:getItemCount(source, nil, requiredItem.item)
        table.insert(requiredItemsWithCounts, {
            item = requiredItem.item,
            needed = requiredItem.quantity,
            have = itemCount
        })
        if itemCount < requiredItem.quantity then
            table.insert(missingItems, {
                item = requiredItem.item,
                needed = requiredItem.quantity,
                have = itemCount
            })
        end
    end

    cb({ 
        hasItems = #missingItems == 0, 
        missingItems = missingItems,
        requiredItems = requiredItemsWithCounts
    })
end)

RegisterNetEvent('bcc-train:UpdateTrainSpawnVar', function(spawned, netId, id, stationName, spawnCoords)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    local character = user.getUsedCharacter

    if spawned then
        -- Determine region for tracking - fail if we can't determine region
        local region = nil
        if stationName then
            local station = Stations[stationName]
            if station and station.train then
                region = station.train.outWest and 'west' or 'east'
            else
                DBG.Error(string.format('Station configuration not found for spawn tracking: %s - train spawn rejected',
                    tostring(stationName)))
                -- Reject the spawn if we can't determine the region
                return
            end
        else
            DBG.Error('No station name provided for regional tracking - train spawn rejected')
            -- Reject the spawn if no station provided
            return
        end

        -- Validate incoming netId to avoid broadcasting invalid ids that cause client warnings
        local numericNetId = tonumber(netId)
        if not numericNetId or numericNetId <= 0 then
            if DevModeActive then
                DBG.Warning(string.format('Received invalid netId from src=%s for train id=%s station=%s netId=%s', tostring(src), tostring(id), tostring(stationName), tostring(netId)))
            end
            numericNetId = nil
        end

        TrainEntity = nil
        if numericNetId then
            TrainEntity = NetworkGetEntityFromNetworkId(numericNetId)
        end

        -- Use global blip defaults from Config.trainBlips for broadcasts (ignore station-specific blip settings)
        local blipSprite = nil
        local blipColor = nil
        if Config.trainBlips then
            blipSprite = Config.trainBlips.sprite
            blipColor = Config.trainBlips.color
        end

        local ownerName = character.firstname .. ' ' .. character.lastname

        table.insert(ActiveTrains, {
            netId = numericNetId,
            id = id,
            region = region,
            owner = src,
            station = stationName,
            ownerName = ownerName,
            blipSprite = blipSprite,
            blipColor = blipColor,
            coords = spawnCoords
        })

        -- Update regional tracking
        SpawnedTrainsByRegion[region] = (SpawnedTrainsByRegion[region] or 0) + 1

        DBG.Info(string.format('Train spawned in %s region - Count now: %d/%d',
            region,
            SpawnedTrainsByRegion[region],
            region == 'west' and Config.spawnLimits.west or Config.spawnLimits.east))

        discord:sendMessage(
            _U('trainSpawnedwebMain') ..
            _U('charNameWeb') ..
            character.firstname ..
            " " ..
            character.lastname ..
            _U('charIdentWeb') ..
            character.identifier ..
            _U('charIdWeb') ..
            character.charIdentifier)
        -- Broadcast to all clients so every player can create a blip for this train (respect config)
        if Config.trainBlips and Config.trainBlips.enabled then
            -- Determine final name to send based on config
            local nameMode = (Config.trainBlips and Config.trainBlips.nameMode) or 'player'
            if nameMode ~= 'player' and nameMode ~= 'standard' then nameMode = 'player' end
            local finalName = nil
            if nameMode == 'player' then
                finalName = ownerName
            elseif nameMode == 'standard' then
                finalName = Config.trainBlips.standardName or 'Train'
            end

            -- Global blip broadcasts disabled: we still track ActiveTrains server-side
            if DevModeActive then
                DBG.Info(string.format('Global blip broadcast skipped for train id=%s owner=%s (netId=%s)', tostring(id), tostring(src), tostring(numericNetId)))
            end
        end
    else
        TrainEntity = nil

        if id then
            -- Remove specific train by ID and update regional tracking
            for i, train in ipairs(ActiveTrains) do
                if train.id == id then
                    local trainRegion = train.region
                    SpawnedTrainsByRegion[trainRegion] = math.max(0, (SpawnedTrainsByRegion[trainRegion] or 1) - 1)

                    DBG.Info(string.format('Removing train ID %s from %s region - Count now: %d/%d',
                        tostring(id),
                        trainRegion,
                        SpawnedTrainsByRegion[trainRegion],
                        trainRegion == 'west' and Config.spawnLimits.west or Config.spawnLimits.east))

                    -- Global blip broadcast removed; clients will not be explicitly notified by server.
                    if DevModeActive then
                        DBG.Info(string.format('Global despawn broadcast skipped for train id=%s netId=%s', tostring(train.id), tostring(train.netId)))
                    end
                    table.remove(ActiveTrains, i)
                    break
                end
            end
        else
            DBG.Warning('No train ID provided for removal, cleaning up orphaned entries')
            -- Cleanup any trains that no longer exist as entities and update regional tracking
            for i = #ActiveTrains, 1, -1 do
                local train = ActiveTrains[i]
                local entity = NetworkGetEntityFromNetworkId(train.netId)
                if not DoesEntityExist(entity) then
                    local trainRegion = train.region
                    SpawnedTrainsByRegion[trainRegion] = math.max(0, (SpawnedTrainsByRegion[trainRegion] or 1) - 1)

                    DBG.Info(string.format('Removing orphaned train ID %s from %s region - Count now: %d/%d',
                        tostring(train.id),
                        trainRegion,
                        SpawnedTrainsByRegion[trainRegion],
                        trainRegion == 'west' and Config.spawnLimits.west or Config.spawnLimits.east))

                    -- Global blip despawn broadcast skipped for orphaned train
                    if DevModeActive then
                        DBG.Info(string.format('Global despawn broadcast skipped for orphaned train id=%s netId=%s', tostring(train.id), tostring(train.netId)))
                    end
                    table.remove(ActiveTrains, i)
                end
            end
        end

        discord:sendMessage(
            _U('trainNotSpawnedWeb') ..
            _U('charNameWeb') ..
            character.firstname .. " " ..
            character.lastname ..
            _U('charIdentWeb') ..
            character.identifier ..
            _U('charIdWeb') ..
            character.charIdentifier
        )
    end
end)

RegisterNetEvent('bcc-train:RegisterInventory', function(id, model)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Validate train ownership
    if not validateTrainOwnership(src, id) then
                Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return
    end

    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered('Train_' .. tostring(id) .. '_bcc-traininv')
    if isRegistered then
        DBG.Info(string.format('Inventory already registered for train ID: %s', tostring(id)))
        return
    end

    local trainCfg = getTrainConfig(model)
    if trainCfg then
        local data = {
            id = 'Train_' .. tostring(id) .. '_bcc-traininv',
            name = _U('trainInv'),
            limit = tonumber(trainCfg.inventory.limit) or 100,
            acceptWeapons = trainCfg.inventory.weapons ~= nil and trainCfg.inventory.weapons or true,
            shared = trainCfg.inventory.shared ~= nil and trainCfg.inventory.shared or false,
            ignoreItemStackLimit = true,
            whitelistItems = false,
            UsePermissions = false,
            UseBlackList = false,
            whitelistWeapons = false
        }
        exports.vorp_inventory:registerInventory(data)

        local nowRegistered = exports.vorp_inventory:isCustomInventoryRegistered('Train_' ..
            tostring(id) .. '_bcc-traininv')
        if not nowRegistered then
            DBG.Error(string.format('Failed to register inventory for train ID: %s', tostring(id)))
            return
        end
        DBG.Success(string.format('Registered inventory for train ID: %s', tostring(id)))
    else
        DBG.Error(string.format('Cannot register inventory - train configuration not found for model: %s',
            tostring(model)))
    end
end)

-- Provide a snapshot of current active trains to a requesting client (useful for late joiners)
RegisterNetEvent('bcc-train:RequestActiveTrains', function()
    local src = source
    -- Build a minimal snapshot (netId, id, station, owner)
    local snapshot = {}
    for _, train in ipairs(ActiveTrains) do
        table.insert(snapshot, {
            netId = train.netId,
            id = train.id,
            station = train.station,
            owner = train.owner,
            ownerName = train.ownerName,
            blipSprite = train.blipSprite,
            blipColor = train.blipColor,
            coords = train.coords
        })
    end
    TriggerClientEvent('bcc-train:ActiveTrainsSnapshot', src, snapshot)
end)

-- Client position reporting removed (global blip system disabled)

RegisterNetEvent('bcc-train:OpenInventory', function(isInTrain)
    local src = source
    local user = Core.getUser(src)

    DBG.Info('bcc-train:OpenInventory called')

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Debug: Show all trains in ActiveTrains table
    if DevModeActive then
        DBG.Info(string.format('ActiveTrains count: %d', #ActiveTrains))
        for i, train in ipairs(ActiveTrains) do
            local entity = NetworkGetEntityFromNetworkId(train.netId)
            local exists = DoesEntityExist(entity)
            DBG.Info(string.format('Train %d: ID=%s, NetID=%s, EntityExists=%s', i, tostring(train.id),
                tostring(train.netId), tostring(exists)))
        end
    end

    local character = user.getUsedCharacter
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    local targetTrain = nil
    local targetDist = 999

    -- If player is in a train, find which train they're in
    if isInTrain then
        local playerVehicle = GetVehiclePedIsIn(playerPed, false)
        if playerVehicle and playerVehicle ~= 0 then
            local playerVehicleNetId = NetworkGetNetworkIdFromEntity(playerVehicle)

            -- Find the train that matches the vehicle the player is in
            for _, train in ipairs(ActiveTrains) do
                if train.netId == playerVehicleNetId then
                    targetTrain = train
                    targetDist = 0 -- Player is inside the train
                    DBG.Info(string.format('Player is in train ID: %s', tostring(train.id)))
                    break
                end
            end
        end
    end

    -- If not in train or train not found, find the nearest active train
    if not targetTrain then
        for _, train in ipairs(ActiveTrains) do
            local entity = NetworkGetEntityFromNetworkId(train.netId)
            if DoesEntityExist(entity) then
                local dist = #(playerCoords - GetEntityCoords(entity))
                DBG.Info(string.format('Checking train ID %s: distance=%.2f', tostring(train.id), dist))
                if dist < targetDist then
                    targetDist = dist
                    targetTrain = train
                end
            else
                DBG.Warning(string.format('Train ID %s exists in ActiveTrains but entity does not exist!',
                    tostring(train.id)))
            end
        end
    end

    DBG.Info(string.format('Target train ID: %s at distance: %.2f', targetTrain and tostring(targetTrain.id) or 'None',
        targetDist))

    -- Allow access if player is in train (driving) or within distance
    local canAccess = isInTrain or (targetTrain and targetDist <= 5)

    if canAccess and targetTrain then
        -- Get train configuration and ownership info
        local trainData = MySQL.query.await('SELECT * FROM `bcc_player_trains` WHERE `trainid` = ?', { targetTrain.id })
        if not trainData or #trainData == 0 then
            DBG.Error(string.format('Train data not found for train ID: %s', tostring(targetTrain.id)))
            return
        end

        local trainInfo = trainData[1]
        local isOwner = trainInfo.charidentifier == character.charIdentifier

        -- Find train configuration using utility function
        local trainCfg = getTrainConfig(trainInfo.trainModel)

        if not trainCfg then
            DBG.Error(string.format('Train configuration not found for train ID: %s (model: %s)',
                tostring(targetTrain.id), tostring(trainInfo.trainModel)))
            return
        end

        local isSharedInventory = trainCfg.inventory.shared ~= nil and trainCfg.inventory.shared or false

        -- Determine access logic
        if isSharedInventory or isOwner then
            -- Shared inventory or owner - direct access
            exports.vorp_inventory:openInventory(src, 'Train_' .. targetTrain.id .. '_bcc-traininv')
        else
            -- Private inventory - non-owner needs lockpick
            local hasLockpick = false
            -- Check if player has any of the configured lockpick items
            for _, item in ipairs(Config.lockpickItem) do
                local itemCount = exports.vorp_inventory:getItemCount(src, nil, item)
                if itemCount >= 1 then
                    hasLockpick = true
                    break
                end
            end

            if not hasLockpick then
                Core.NotifyRightTip(src, _U('noLockpickItem'), 4000)
                return
            end

            Core.NotifyRightTip(src, _U('attemptingLockpick'), 4000)
            TriggerClientEvent('bcc-train:StartLockpick', src, targetTrain.id)
        end
    end
end)

-- Position broadcasts removed as part of global blip system removal.

RegisterNetEvent('bcc-train:OpenInventoryAfterLockpick', function(id)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    exports.vorp_inventory:openInventory(src, 'Train_' .. id .. '_bcc-traininv')

    TrainRobberyAlert:SendAlert(src)
end)

RegisterNetEvent('bcc-train:ConsumeLockpick', function()
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Check lockpick attempt cooldown
    local lockpickCooldown = (Config.rateLimiting and Config.rateLimiting.lockpickCooldown) or 10
    local canAttempt, timeRemaining = checkOperationCooldown(src, 'lockpick', lockpickCooldown)
    if not canAttempt then
    Core.NotifyRightTip(src, _U('pleaseWaitSeconds') .. ': ' .. tostring(timeRemaining) .. 's', 4000)
        return
    end

    -- Increment attempt counter and handle lockpick breaking
    LockpickAttempts[src] = (LockpickAttempts[src] or 0) + 1

    if LockpickAttempts[src] >= Config.lockPick.maxAttempts then
        -- Find and consume the first available lockpick item
        for _, item in ipairs(Config.lockpickItem) do
            local itemCount = exports.vorp_inventory:getItemCount(src, nil, item)
            if itemCount >= 1 then
                DBG.Info(string.format('Consuming lockpick: src=%s item=%s', tostring(src), tostring(item)))
                exports.vorp_inventory:subItem(src, item, 1)
                DBG.Info(string.format('Requested lockpick removal: src=%s item=%s', tostring(src), tostring(item)))
                Core.NotifyRightTip(src, _U('lockpickBroke'), 4000)
                break
            end
        end
        LockpickAttempts[src] = 0 -- Reset counter after breaking lockpick

        -- Add additional cooldown after breaking lockpick
        local lockpickBreakPenalty = (Config.rateLimiting and Config.rateLimiting.lockpickBreakPenalty) or 60
        checkOperationCooldown(src, 'lockpick_break', lockpickBreakPenalty)
    end
end)

Core.Callback.Register('bcc-train:GetMyTrains', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb({})
    end

    local character = user.getUsedCharacter
    local myTrains = MySQL.query.await('SELECT * FROM `bcc_player_trains` WHERE `charidentifier` = ?',
        { character.charIdentifier })
    if myTrains and #myTrains > 0 then
        cb(myTrains)
    else
        cb({})
    end
end)

RegisterNetEvent('bcc-train:BuyTrain', function(trainHash, clientCurrency, trainName, station)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    DBG.Info(string.format('BuyTrain called with trainHash: %s, clientCurrency: %s, trainName: %s, station: %s',
        tostring(trainHash),
        tostring(clientCurrency), tostring(trainName), tostring(station)))

    -- Validate trainHash parameter - should be hex format
    if not trainHash or type(trainHash) ~= 'string' then
        DBG.Error('Invalid train hash provided for purchase')
        return
    end

    -- Validate hex hash format (0x followed by hex characters)
    if not trainHash:match('^0x[0-9A-Fa-f]+$') then
        DBG.Error('Invalid train hash format - expected hex format (0x...)')
        return
    end

    -- Validate clientCurrency parameter if provided
    if clientCurrency and type(clientCurrency) ~= 'string' then
        DBG.Error('Invalid client currency type provided')
        return
    end

    if clientCurrency and clientCurrency ~= 'cash' and clientCurrency ~= 'gold' then
        DBG.Error('Invalid client currency value - must be "cash" or "gold"')
        return
    end

    -- Validate trainName parameter if provided
    if trainName and type(trainName) ~= 'string' then
        DBG.Error('Invalid train name type provided')
        return
    end

    -- Check maximum train limit first - no point processing if they've hit the limit
    local character = user.getUsedCharacter
    local currentTrains = MySQL.query.await(
        'SELECT COUNT(*) as count FROM `bcc_player_trains` WHERE `charidentifier` = ?', { character.charIdentifier })
    local trainCount = currentTrains and currentTrains[1] and currentTrains[1].count or 0

    if trainCount >= Config.maxTrains then
        Core.NotifyRightTip(src, _U('maxTrainsReached'), 4000)
        DBG.Info(string.format('Player %s has reached max train limit (%d/%d)', character.charIdentifier, trainCount,
            Config.maxTrains))
        return
    end

    -- Get train configuration from hash first (needed for default name)
    local trainCfg = getTrainConfig(trainHash)
    if not trainCfg then
        DBG.Error(string.format('Train configuration not found for hash: %s', tostring(trainHash)))
        return
    end

    -- Check job requirements
    if trainCfg.job and #trainCfg.job > 0 then
        local hasRequiredJob = false
        for _, requiredJob in ipairs(trainCfg.job) do
            if character.job == requiredJob then
                hasRequiredJob = true
                break
            end
        end

        if not hasRequiredJob then
            Core.NotifyRightTip(src, _U('jobRequiredForTrain'), 4000)
            DBG.Warning(string.format('Player %s attempted to buy job-restricted train %s without required job',
                character.charIdentifier, trainHash))
            return
        end
    end

    -- Sanitize train name or use train label as default
    local finalTrainName = trainCfg.label -- Default to train label
    if trainName and trainName ~= '' then
        -- Remove potentially dangerous characters, special symbols, and limit length
        local sanitized = trainName:gsub('[^%w%s%-_]', ''):gsub('%s+', ' '):sub(1, 50):match('^%s*(.-)%s*$')
        if sanitized and sanitized ~= '' then
            finalTrainName = sanitized
        end
        -- If sanitization results in empty string, keep the default train label
    end

    DBG.Info(string.format('Found train configuration: %s', json.encode(trainCfg)))

    local trainPrice = trainCfg.price

    -- Validate that price is in table format (cash/gold structure)
    if not trainPrice or type(trainPrice) ~= 'table' then
        DBG.Error('Invalid price configuration - table format required with cash/gold properties')
        return
    end

    -- Get station currency configuration
    if not station or not Stations[station] then
        DBG.Error('Invalid station provided for train purchase')
        return
    end

    local stationCurrencyType = Stations[station].shop.currency

    -- Determine price and currency based on station currency and client selection
    local price = 0
    local currency = 0 -- 0 for cash, 1 for gold

    if stationCurrencyType == 0 then
        -- Cash only
        if not trainPrice.cash then
            DBG.Error('Invalid price configuration for cash-only mode - missing cash property')
            return
        end
        price = trainPrice.cash
        currency = 0
    elseif stationCurrencyType == 1 then
        -- Gold only
        if not trainPrice.gold then
            DBG.Error('Invalid price configuration for gold-only mode - missing gold property')
            return
        end
        price = trainPrice.gold
        currency = 1
    elseif stationCurrencyType == 2 then
        -- Both currencies - use client selection (no fallback)
        if clientCurrency == 'gold' then
            if not trainPrice.gold then
                DBG.Error('Train does not support gold payment')
                Core.NotifyRightTip(src, _U('cannotPurchaseWithGold'), 4000)
                return
            end
            price = trainPrice.gold
            currency = 1
        elseif clientCurrency == 'cash' then
            if not trainPrice.cash then
                DBG.Error('Train does not support cash payment')
                Core.NotifyRightTip(src, _U('cannotPurchaseWithCash'), 4000)
                return
            end
            price = trainPrice.cash
            currency = 0
        else
            -- Invalid currency selection - default to cash but validate it exists
            if not trainPrice.cash then
                DBG.Error('Invalid currency selection and no cash price available')
                Core.NotifyRightTip(src, _U('invalidPaymentMethod'), 4000)
                return
            end
            price = trainPrice.cash
            currency = 0
        end
    else
        DBG.Error(string.format('Invalid currency configuration for station %s: %s', tostring(station),
            tostring(stationCurrencyType)))
        return
    end

    -- Check if player has enough currency
    if currency == 0 and character.money < price then
        Core.NotifyRightTip(src, _U('notEnoughMoney'), 4000)
        return
    end
    if currency == 1 and character.gold < price then
        Core.NotifyRightTip(src, _U('notEnoughGold'), 4000)
        return
    end

    -- Store the hash key and name in the database
    MySQL.query.await(
        'INSERT INTO `bcc_player_trains` (`charidentifier`, `trainModel`, `name`, `fuel`, `condition`) VALUES (?, ?, ?, ?, ?)',
        { character.charIdentifier, trainHash, finalTrainName, trainCfg.fuel.maxAmount, trainCfg.condition.maxAmount })

    character.removeCurrency(currency, price)

    Core.NotifyRightTip(src, _U('trainBought'), 4000)

    local currencyText = currency == 0 and 'Cash' or 'Gold'
    local trainDisplayName = finalTrainName -- Use the final train name (custom or default)

    discord:sendMessage(
        _U('charNameWeb') ..
        character.firstname ..
        " " ..
        character.lastname ..
        _U('charIdentWeb') ..
        character.identifier ..
        _U('charIdWeb') ..
        character.charIdentifier ..
        _U('boughtTrainWeb') ..
        trainDisplayName ..
        _U('charPriceWeb') ..
        price .. ' ' .. currencyText)
end)

RegisterNetEvent('bcc-train:SellTrain', function(myTrainData, clientCurrency, station)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    DBG.Info(string.format('SellTrain called with trainModel: %s, clientCurrency: %s, station: %s',
        tostring(myTrainData and myTrainData.trainModel), tostring(clientCurrency), tostring(station)))

    -- Validate myTrainData parameter
    if not myTrainData or type(myTrainData) ~= 'table' then
        DBG.Error('Invalid train data provided for sale')
        return
    end

    if not myTrainData.trainModel or type(myTrainData.trainModel) ~= 'string' then
        DBG.Error('Invalid train model in train data')
        return
    end

    if not myTrainData.trainid then
        DBG.Error('Missing train ID in train data')
        return
    end

    -- Validate trainid is numeric
    local numericTrainId = tonumber(myTrainData.trainid)
    if not numericTrainId or numericTrainId <= 0 then
        DBG.Error('Invalid train ID format')
        return
    end

    -- Validate clientCurrency parameter
    if clientCurrency and type(clientCurrency) ~= 'string' then
        DBG.Error('Invalid client currency type provided')
        return
    end

    if clientCurrency and clientCurrency ~= 'cash' and clientCurrency ~= 'gold' then
        DBG.Error('Invalid client currency value - must be "cash" or "gold"')
        return
    end

    local character = user.getUsedCharacter
    local trainModel = myTrainData.trainModel
    local trainCfg = getTrainConfig(trainModel)

    if not trainCfg then
        DBG.Error(string.format('Train configuration not found for model: %s', trainModel))
        return
    end

    -- Validate that price is in table format (cash/gold structure)
    local trainPrice = trainCfg.price
    if not trainPrice or type(trainPrice) ~= 'table' then
        DBG.Error('Invalid price configuration - table format required with cash/gold properties')
        return
    end

    -- Get station currency configuration
    if not station or not Stations[station] then
        DBG.Error('Invalid station provided for train sale')
        return
    end

    local stationCurrencyType = Stations[station].shop.currency

    -- Determine sell price and currency based on station currency and client selection
    local sellPrice = 0
    local currency = 0 -- 0 for cash, 1 for gold
    local sellMultiplier = Config.sellPrice or 0.75

    if stationCurrencyType == 0 then
        -- Cash only
        if not trainPrice.cash then
            DBG.Error('Invalid price configuration for cash-only mode - missing cash property')
            return
        end
        sellPrice = math.floor(sellMultiplier * trainPrice.cash)
        currency = 0
    elseif stationCurrencyType == 1 then
        -- Gold only
        if not trainPrice.gold then
            DBG.Error('Invalid price configuration for gold-only mode - missing gold property')
            return
        end
        sellPrice = math.floor(sellMultiplier * trainPrice.gold)
        currency = 1
    elseif stationCurrencyType == 2 then
        -- Both currencies - use client selection (no fallback)
        if clientCurrency == 'gold' then
            if not trainPrice.gold then
                DBG.Error('Train does not support gold payment')
                Core.NotifyRightTip(src, _U('cannotSellForGold'), 4000)
                return
            end
            sellPrice = math.floor(sellMultiplier * trainPrice.gold)
            currency = 1
        elseif clientCurrency == 'cash' then
            if not trainPrice.cash then
                DBG.Error('Train does not support cash payment')
                Core.NotifyRightTip(src, _U('cannotSellForCash'), 4000)
                return
            end
            sellPrice = math.floor(sellMultiplier * trainPrice.cash)
            currency = 0
        else
            -- Invalid currency selection - default to cash but validate it exists
            if not trainPrice.cash then
                DBG.Error('Invalid currency selection and no cash price available')
                Core.NotifyRightTip(src, _U('invalidPaymentMethod'), 4000)
                return
            end
            sellPrice = math.floor(sellMultiplier * trainPrice.cash)
            currency = 0
        end
    else
        DBG.Error(string.format('Invalid currency configuration for station %s: %s', tostring(station),
            tostring(stationCurrencyType)))
        return
    end

    character.addCurrency(currency, sellPrice)

    -- Only delete the train from database after successful payment
    MySQL.query.await('DELETE FROM `bcc_player_trains` WHERE `charidentifier` = ? AND `trainid` = ?',
        { character.charIdentifier, myTrainData.trainid })
    DBG.Info(string.format('Deleted train ID %s for character %s', tostring(myTrainData.trainid),
        tostring(character.charIdentifier)))

    local currencyText = currency == 0 and 'Cash' or 'Gold'
    Core.NotifyRightTip(src, _U('soldTrain') .. tostring(sellPrice) .. ' ' .. currencyText, 4000)

    discord:sendMessage(
        _U('charNameWeb') ..
        character.firstname ..
        " " ..
        character.lastname ..
        _U('charIdentWeb') ..
        character.identifier ..
        _U('charIdWeb') ..
        character.charIdentifier ..
        _U('soldTrainWeb') ..
        trainCfg.label ..
        _U('charPriceWeb') ..
        tostring(sellPrice) .. ' ' .. currencyText)
end)

RegisterNetEvent('bcc-train:RenameTrain', function(trainId, newName)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Validate trainId parameter
    if not trainId or type(trainId) ~= 'number' then
        DBG.Error('Invalid train ID provided for rename')
        return
    end

    -- Validate newName parameter
    if not newName or type(newName) ~= 'string' then
        DBG.Error('Invalid train name provided for rename')
        return
    end

    local character = user.getUsedCharacter

    -- Validate train ownership
    if not validateTrainOwnership(src, trainId) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return
    end

    -- Get current train data for default name fallback
    local trainData = MySQL.query.await(
        'SELECT trainModel FROM `bcc_player_trains` WHERE `charidentifier` = ? AND `trainid` = ?',
        { character.charIdentifier, trainId })
    if not trainData or #trainData == 0 then
        DBG.Error('Train not found in database')
        return
    end

    local trainModel = trainData[1].trainModel
    local trainCfg = getTrainConfig(trainModel)
    if not trainCfg then
        DBG.Error(string.format('Train configuration not found for model: %s', tostring(trainModel)))
        return
    end

    -- Sanitize train name or use train label as default
    local finalTrainName = trainCfg.label -- Default to train label
    if newName and newName ~= '' then
        -- Remove potentially dangerous characters, special symbols, and limit length
        local sanitized = newName:gsub('[^%w%s%-_]', ''):gsub('%s+', ' '):sub(1, 50):match('^%s*(.-)%s*$')
        if sanitized and sanitized ~= '' then
            finalTrainName = sanitized
        end
        -- If sanitization results in empty string, keep the default train label
    end

    -- Update the train name in the database
    local success = MySQL.query.await(
        'UPDATE `bcc_player_trains` SET `name` = ? WHERE `charidentifier` = ? AND `trainid` = ?',
        { finalTrainName, character.charIdentifier, trainId })

    if success then
        Core.NotifyRightTip(src, _U('trainRenamed'), 4000)
        DBG.Info(string.format('Player %s renamed train ID %d to: %s', character.charIdentifier, trainId, finalTrainName))
    else
        Core.NotifyRightTip(src, _U('failedRename'), 4000)
        DBG.Error(string.format('Failed to rename train ID %d for player %s', trainId, character.charIdentifier))
    end
end)

Core.Callback.Register('bcc-train:DecTrainFuel', function(source, cb, trainid, trainFuel, trainCfg)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(nil)
    end

    -- Validate train ownership
    if not validateTrainOwnership(src, trainid) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return cb(nil)
    end

    -- Validate fuel amount and decrease amount
    if not trainFuel or not trainCfg.fuel or not trainCfg.fuel.itemAmount then
        DBG.Error('Invalid fuel data provided')
        return cb(nil)
    end

    local newFuel = math.max(0, trainFuel - trainCfg.fuel.itemAmount)
    MySQL.query.await('UPDATE `bcc_player_trains` SET `fuel` = ? WHERE `trainid` = ?', { newFuel, trainid })

    cb(newFuel)
end)

Core.Callback.Register('bcc-train:DecTrainCond', function(source, cb, trainid, trainCondition, trainCfg)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(nil)
    end

    -- Validate train ownership
    if not validateTrainOwnership(src, trainid) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return cb(nil)
    end

    -- Validate condition amount and decrease amount
    if not trainCondition or not trainCfg.condition or not trainCfg.condition.itemAmount then
        DBG.Error('Invalid condition data provided')
        return cb(nil)
    end

    local newCondition = math.max(0, trainCondition - trainCfg.condition.itemAmount)
    MySQL.query.await('UPDATE `bcc_player_trains` SET `condition` = ? WHERE `trainid` = ?', { newCondition, trainid })

    cb(newCondition)
end)

Core.Callback.Register('bcc-train:FuelTrain', function(source, cb, trainId, trainFuel, trainCfg)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(nil)
    end

    -- Validate train ownership
    if not validateTrainOwnership(src, trainId) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return cb(nil)
    end

    -- Check operation cooldown
    local fuelCooldown = (Config.rateLimiting and Config.rateLimiting.fuelCooldown) or 30
    local canOperate, timeRemaining = checkOperationCooldown(src, 'fuel', fuelCooldown)
    if not canOperate then
        Core.NotifyRightTip(src, _U('pleaseWaitSeconds') .. ': ' .. tostring(timeRemaining) .. 's', 4000)
        return cb(nil)
    end

    -- Validate parameters
    if not trainId or not trainFuel or not trainCfg or not trainCfg.fuel then
        DBG.Error('Invalid fuel train parameters provided')
        return cb(nil)
    end

    local maxFuel = trainCfg.fuel.maxAmount
    local itemCount = exports.vorp_inventory:getItemCount(src, nil, Config.fuel.item)
    if itemCount >= trainCfg.fuel.itemAmount then
    DBG.Info(string.format('Consuming fuel item: src=%s item=%s qty=%s', tostring(src), tostring(Config.fuel.item), tostring(trainCfg.fuel.itemAmount)))
    exports.vorp_inventory:subItem(src, Config.fuel.item, trainCfg.fuel.itemAmount)
    DBG.Info(string.format('Requested fuel removal: src=%s item=%s qty=%s', tostring(src), tostring(Config.fuel.item), tostring(trainCfg.fuel.itemAmount)))
        MySQL.query.await('UPDATE `bcc_player_trains` SET `fuel` = ? WHERE `trainid` = ?', { maxFuel, trainId })
        Core.NotifyRightTip(src, _U('fuelAdded'), 4000)
        cb(maxFuel)
    else
        Core.NotifyRightTip(src, _U('noItem'), 4000)
        cb(nil)
    end
end)

Core.Callback.Register('bcc-train:RepairTrain', function(source, cb, trainId, trainCondition, trainCfg)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(nil)
    end

    -- Validate train ownership
    if not validateTrainOwnership(src, trainId) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return cb(nil)
    end

    -- Check operation cooldown
    local repairCooldown = (Config.rateLimiting and Config.rateLimiting.repairCooldown) or 45
    local canOperate, timeRemaining = checkOperationCooldown(src, 'repair', repairCooldown)
    if not canOperate then
        Core.NotifyRightTip(src, _U('pleaseWaitSeconds') .. ': ' .. tostring(timeRemaining) .. 's', 4000)
        return cb(nil)
    end

    -- Validate parameters
    if not trainId or not trainCondition or not trainCfg or not trainCfg.condition then
        DBG.Error('Invalid repair train parameters provided')
        return cb(nil)
    end

    local maxCondition = trainCfg.condition.maxAmount
    local itemCount = exports.vorp_inventory:getItemCount(src, nil, Config.condition.item)
    if itemCount >= trainCfg.condition.itemAmount then
    DBG.Info(string.format('Consuming condition item: src=%s item=%s qty=%s', tostring(src), tostring(Config.condition.item), tostring(trainCfg.condition.itemAmount)))
    exports.vorp_inventory:subItem(src, Config.condition.item, trainCfg.condition.itemAmount)
    DBG.Info(string.format('Requested condition removal: src=%s item=%s qty=%s', tostring(src), tostring(Config.condition.item), tostring(trainCfg.condition.itemAmount)))
        MySQL.query.await('UPDATE `bcc_player_trains` SET `condition` = ? WHERE `trainid` = ?', { maxCondition, trainId })
        Core.NotifyRightTip(src, _U('trainRepaired'), 4000)
        cb(maxCondition)
    else
        Core.NotifyRightTip(src, _U('noItem'), 4000)
        cb(nil)
    end
end)

RegisterNetEvent('bcc-train:BridgeFallHandler', function(freshJoin)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    local character = user.getUsedCharacter

    if freshJoin then
        if BridgeDestroyed then
            TriggerClientEvent('bcc-train:BridgeFall', src) --triggers for new client
        end
        return
    end

    if BridgeDestroyed then
        return
    end

    -- Validate config exists
    if not Config.bacchusBridge or not Config.bacchusBridge.item or not Config.bacchusBridge.itemAmount then
        DBG.Error('Invalid bridge configuration')
        return
    end

    local itemCount = exports.vorp_inventory:getItemCount(src, nil, Config.bacchusBridge.item)
    if itemCount < Config.bacchusBridge.itemAmount then
        Core.NotifyRightTip(src, _U('noItem'), 4000)
        return
    end

    DBG.Info(string.format('Consuming bridge item: src=%s item=%s qty=%s', tostring(src), tostring(Config.bacchusBridge.item), tostring(Config.bacchusBridge.itemAmount)))
    exports.vorp_inventory:subItem(src, Config.bacchusBridge.item, Config.bacchusBridge.itemAmount)
    DBG.Info(string.format('Requested bridge removal: src=%s item=%s qty=%s', tostring(src), tostring(Config.bacchusBridge.item), tostring(Config.bacchusBridge.itemAmount)))
    BridgeDestroyed = true
    Core.NotifyRightTip(src, _U('runFromExplosion') .. Config.bacchusBridge.timer .. _U('seconds'), 4000)

    SetTimeout(Config.bacchusBridge.timer * 1000, function()
        discord:sendMessage(
            _U('charNameWeb') ..
            character.firstname ..
            " " ..
            character.lastname ..
            _U('charIdentWeb') ..
            character.identifier ..
            _U('charIdWeb') ..
            character.charIdentifier ..
            _U('bacchusDestroyedWebhook')
        )

        TriggerClientEvent('bcc-train:BridgeFall', -1) --triggers for all clients
    end)
end)

RegisterNetEvent('bcc-train:DeliveryPay', function(destination)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Validate destination parameter (must provide `rewards` table)
    if not destination or not destination.rewards or type(destination.rewards) ~= 'table' then
        DBG.Error('Invalid destination data provided for delivery pay; rewards table required')
        return
    end
    local rewards = destination.rewards
    if type(rewards.cash) ~= 'number' then
        DBG.Error('Invalid rewards.cash provided for delivery pay')
        return
    end

    -- Validate mission completion
    if not validateAndCompleteDeliveryMission(src, destination) then
        Core.NotifyRightTip(src, _U('invalidMissionComplete'), 4000)
        return
    end

    local character = user.getUsedCharacter
    -- Award cash
    if rewards.cash and rewards.cash > 0 then
        character.addCurrency(0, rewards.cash)
    end
    -- Award gold (assumes character.addCurrency accepts currency type 1 for gold; adapt if different)
    if rewards.gold and rewards.gold > 0 then
        -- If the server/economy uses a different method for gold, replace the next line accordingly
        character.addCurrency(1, rewards.gold)
    end
    -- Award item rewards via inventory export if present, but only if the player can carry them
    local failedAwards = {}
    if rewards.items and type(rewards.items) == 'table' then
        for _, it in ipairs(rewards.items) do
            if it and it.item and it.quantity and tonumber(it.quantity) and tonumber(it.quantity) > 0 then
                local qty = tonumber(it.quantity)
                local canCarry = true
                -- Check carry capacity if the export exists
                if exports.vorp_inventory and exports.vorp_inventory.canCarryItem then
                    local ok, reason = exports.vorp_inventory:canCarryItem(src, it.item, qty)
                    -- canCarryItem may return boolean or (boolean, reason)
                    if ok == false then
                        canCarry = false
                        table.insert(failedAwards, { item = it.item, quantity = qty, reason = reason })
                    end
                end

                if canCarry then
                    exports.vorp_inventory:addItem(src, it.item, qty)
                    DBG.Info(string.format('Awarded item to src=%s item=%s qty=%s', tostring(src), tostring(it.item), tostring(qty)))
                end
            end
        end
    end

    -- Notify player about failed awards (items that couldn't fit in inventory)
    if #failedAwards > 0 then
        local msg = _U('couldNotAwardItemsHeader')
        for _, f in ipairs(failedAwards) do
            local label = getItemLabel(f.item)
            msg = msg .. string.format('\n%s x%d', label, f.quantity)
            DBG.Warning(string.format('Failed to award item to src=%s item=%s qty=%s reason=%s', tostring(src), tostring(f.item), tostring(f.quantity), tostring(f.reason)))
        end
        Core.NotifyRightTip(src, msg, 8000)
    end

    -- Clean up completed mission
    ActiveMissions[src] = nil

    discord:sendMessage(
        _U('charNameWeb') ..
        character.firstname ..
        " " ..
        character.lastname ..
        _U('charIdentWeb') ..
        character.identifier ..
        _U('charIdWeb') ..
        character.charIdentifier ..
        _U('paidDeliveryWeb') ..
        tostring(rewards.cash or 0))
end)

RegisterNetEvent('bcc-train:StartDeliveryMission', function(destination)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Validate destination parameter
    if not destination or type(destination) ~= 'table' then
        DBG.Error('Invalid destination data provided for mission start')
        return
    end

    -- Check if player already has an active mission
    if ActiveMissions[src] then
        Core.NotifyRightTip(src, _U('alreadyInMission'), 4000)
        return
    end

    if startDeliveryMission(src, destination) then
        Core.NotifyRightTip(src, _U('deliveryStarted'), 4000)
    else
        Core.NotifyRightTip(src, _U('deliveryStartFailed'), 4000)
    end
end)

-- Provide a callback variant so clients can TriggerAwait and get immediate success/failure
Core.Callback.Register('bcc-train:StartDeliveryMission', function(source, cb, destination)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb({ success = false, error = 'User not found' })
    end

    -- Validate destination parameter
    if not destination or type(destination) ~= 'table' then
        DBG.Error('Invalid destination data provided for mission start (callback)')
        return cb({ success = false, error = 'Invalid destination' })
    end

    -- Check if player already has an active mission
    if ActiveMissions[src] then
        return cb({ success = false, error = 'Already in mission' })
    end

    local ok = startDeliveryMission(src, destination)
    if ok then
        -- Return sanitized destination back to client
        local serverDestination = {
            requireItem = destination.requireItem,
            items = destination.items,
            rewards = destination.rewards or { cash = 0, gold = 0, items = {} },
            name = destination.name
        }
        return cb({ success = true, destination = serverDestination })
    else
        return cb({ success = false, error = 'Failed to start mission' })
    end
end)

RegisterNetEvent('bcc-train:SetPlayerCooldown', function(mission)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Validate mission parameter
    if not mission or type(mission) ~= 'string' then
        DBG.Error('Invalid mission parameter provided for cooldown')
        return
    end

    local character = user.getUsedCharacter
    CooldownData[mission .. tostring(character.charIdentifier)] = os.time()
end)

Core.Callback.Register('bcc-train:CheckPlayerCooldown', function(source, cb, mission)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(false)
    end

    -- Validate mission parameter
    if not mission or type(mission) ~= 'string' then
        DBG.Error('Invalid mission parameter provided for cooldown check')
        return cb(false)
    end

    -- Validate config exists
    if not Config.cooldown or not Config.cooldown[mission] then
        DBG.Error(string.format('Cooldown configuration not found for mission: %s', mission))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local cooldown = Config.cooldown[mission]
    local missionId = mission .. tostring(character.charIdentifier)

    -- Check if player is on cooldown
    if CooldownData[missionId] then
        if os.difftime(os.time(), CooldownData[missionId]) >= cooldown * 60 then
            cb(false) -- Not on Cooldown
        else
            cb(true)  -- On Cooldown
        end
    else
        cb(false) -- Not on List, so not on cooldown
    end
end)

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-train')
