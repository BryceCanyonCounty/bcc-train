-- Server events: miscellaneous event handlers and utilities

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

    return cb(getItemData(item))
end)

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
        return cb(false)
    else
        return cb(true)
    end
end)

Core.Callback.Register('bcc-train:RequestActiveTrains', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb({})
    end

    -- Build a minimal snapshot (netId, id, station, owner)
    local snapshot = {}
    if ActiveTrains and type(ActiveTrains) == 'table' then
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
    else
        DBG.Warning('ActiveTrains is nil or not a table in RequestActiveTrains callback')
    end

    return cb(snapshot)
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
        Discord:sendMessage(
            _U('charNameWeb') ..
            character.firstname ..
            ' ' ..
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
