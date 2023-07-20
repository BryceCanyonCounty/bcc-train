-- Check If train is spawned or in use
exports('CheckIfTrainIsSpawned', function()
    if TrainSpawned then
        return true
    else
        return false
    end
end)