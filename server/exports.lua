-- Check If train is spawned or in use
exports('CheckIfTrainIsSpawned', function()
    local success, result = pcall(function()
        return TrainSpawned == true
    end)

    if not success then
        print(string.format("ERROR in CheckIfTrainIsSpawned export: %s", result))
        return false
    end

    return result
end)

-- Get Train Entity
exports('GetTrainEntity', function()
    local success, result = pcall(function()
        if TrainSpawned and TrainEntity then
            -- Validate that the entity still exists
            if DoesEntityExist(TrainEntity) then
                return TrainEntity
            else
                -- Entity no longer exists, reset state
                TrainSpawned = false
                TrainEntity = nil
                return false
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
