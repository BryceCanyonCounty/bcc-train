-- Train operations: fuel, condition, spawn tracking, and inventory

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

        Discord:sendMessage(
            _U('trainSpawnedwebMain') ..
            _U('charNameWeb') ..
            character.firstname ..
            ' ' ..
            character.lastname ..
            _U('charIdentWeb') ..
            character.identifier ..
            _U('charIdWeb') ..
            character.charIdentifier)
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

        Discord:sendMessage(
            _U('trainNotSpawnedWeb') ..
            _U('charNameWeb') ..
            character.firstname .. ' ' ..
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
    if not ValidateTrainOwnership(src, id) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return
    end

    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered('Train_' .. tostring(id) .. '_bcc-traininv')
    if isRegistered then
        DBG.Info(string.format('Inventory already registered for train ID: %s', tostring(id)))
        return
    end

    local trainCfg = GetTrainConfig(model)
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

        local nowRegistered = exports.vorp_inventory:isCustomInventoryRegistered('Train_' .. tostring(id) .. '_bcc-traininv')
        if not nowRegistered then
            DBG.Error(string.format('Failed to register inventory for train ID: %s', tostring(id)))
            return
        end
        DBG.Success(string.format('Registered inventory for train ID: %s', tostring(id)))
    else
        DBG.Error(string.format('Cannot register inventory - train configuration not found for model: %s', tostring(model)))
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
    if not ValidateTrainOwnership(src, trainid) then
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

    return cb(newFuel)
end)

Core.Callback.Register('bcc-train:DecTrainCond', function(source, cb, trainid, trainCondition, trainCfg)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(nil)
    end

    -- Validate train ownership
    if not ValidateTrainOwnership(src, trainid) then
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

    return cb(newCondition)
end)

Core.Callback.Register('bcc-train:FuelTrain', function(source, cb, trainId, trainFuel, trainCfg)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(nil)
    end

    -- Validate train ownership
    if not ValidateTrainOwnership(src, trainId) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return cb(nil)
    end

    -- Check operation cooldown
    local fuelCooldown = (Config.rateLimiting and Config.rateLimiting.fuelCooldown) or 30
    local canOperate, timeRemaining = CheckOperationCooldown(src, 'fuel', fuelCooldown)
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
        return cb(maxFuel)
    else
        Core.NotifyRightTip(src, _U('noItem'), 4000)
        return cb(nil)
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
    if not ValidateTrainOwnership(src, trainId) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return cb(nil)
    end

    -- Check operation cooldown
    local repairCooldown = (Config.rateLimiting and Config.rateLimiting.repairCooldown) or 45
    local canOperate, timeRemaining = CheckOperationCooldown(src, 'repair', repairCooldown)
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
        return cb(maxCondition)
    else
        Core.NotifyRightTip(src, _U('noItem'), 4000)
        return cb(nil)
    end
end)
