-- Check If player has an active train spawned
--- @param source number - Player server ID (optional, defaults to invoking resource's source)
--- @return boolean - true if player has an active train
exports('CheckIfTrainIsSpawned', function(source)
    local success, result = pcall(function()
        local playerId = source or source
        if not playerId then
            DBG.Warning('CheckIfTrainIsSpawned called without valid source')
            return false
        end

        -- Check if player has an active train
        for _, train in ipairs(ActiveTrains) do
            if train.owner == playerId then
                return true
            end
        end
        return false
    end)

    if not success then
        print(string.format("ERROR in CheckIfTrainIsSpawned export: %s", result))
        return false
    end

    return result
end)

-- Get Train Entity network ID for a specific player
--- @param source number - Player server ID (optional, defaults to invoking resource's source)
--- @return number|boolean - Network ID of player's train entity, or false if none
exports('GetTrainEntity', function(source)
    local success, result = pcall(function()
        local playerId = source or source
        if not playerId then
            DBG.Warning('GetTrainEntity called without valid source')
            return false
        end

        -- Find player's active train
        for _, train in ipairs(ActiveTrains) do
            if train.owner == playerId then
                -- Validate that the entity still exists
                if train.netId and NetworkGetEntityFromNetworkId(train.netId) ~= 0 then
                    return train.netId
                else
                    -- Entity no longer exists, should be cleaned up
                    DBG.Warning(string.format('Player %s has active train record but entity does not exist', playerId))
                    return false
                end
            end
        end
        return false
    end)

    if not success then
        print(string.format("ERROR in GetTrainEntity export: %s", result))
        return false
    end

    return result
end)

-- Check if bacchus bridge destroyed
--- @return boolean - true if bridge is currently destroyed
exports('BacchusBridgeDestroyed', function()
    local success, result = pcall(function()
        return BridgeDestroyed == true
    end)

    if not success then
        print(string.format("ERROR in BacchusBridgeDestroyed export: %s", result))
        return false
    end

    return result
end)
