-- Train inventory: access, lockpicking, and item checks

Core.Callback.Register('bcc-train:CheckDeliveryItems', function(source, cb, destination)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb({ hasItems = false, missingItems = {}, error = 'User not found' })
    end

    -- Handle invalid destination
    if not destination then
        DBG.Error('CheckDeliveryItems called without destination')
        return cb({ hasItems = false, missingItems = {}, error = 'Invalid destination' })
    end

    -- If no item requirements, allow mission to proceed
    if not destination.requireItem or not destination.items then
        return cb({ hasItems = true, missingItems = {} })
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

    return cb({
        hasItems = #missingItems == 0,
        missingItems = missingItems,
        requiredItems = requiredItemsWithCounts
    })
end)

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

    DBG.Info(string.format('Target train ID: %s at distance: %.2f', targetTrain and tostring(targetTrain.id) or 'None', targetDist))

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
        local trainCfg = GetTrainConfig(trainInfo.trainModel)

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
    local canAttempt, timeRemaining = CheckOperationCooldown(src, 'lockpick', lockpickCooldown)

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
        CheckOperationCooldown(src, 'lockpick_break', lockpickBreakPenalty)
    end
end)
