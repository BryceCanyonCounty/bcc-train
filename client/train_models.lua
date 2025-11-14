---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

function LoadTrainCars(trainHash, isPreview)
    if not trainHash or trainHash == 0 then
        DBG.Error('Invalid trainHash provided to LoadTrainCars')
        return false
    end

    local cars = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash) -- GetNumCarsFromTrainConfig
    if cars == 0 then
        DBG.Error(string.format('Invalid train configuration - no cars found for train hash: %s', tostring(trainHash)))
        return false
    end

    -- Only log for actual spawning, not previews (reduce spam)
    if not isPreview then
        DBG.Info(string.format('Loading %d car(s) for train hash: %s', cars, tostring(trainHash)))
    end

    for index = 0, cars - 1 do
        local model = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, index) -- GetTrainModelFromTrainConfigByCarIndex
        if model ~= 0 then
            RequestModel(model, false)
            -- Set timeout (5 seconds)
            local timeout = 5000
            local startTime = GetGameTimer()

            -- Wait for model to load
            while not HasModelLoaded(model) do
                -- Check for timeout
                if GetGameTimer() - startTime > timeout then
                    DBG.Error(string.format('Timeout while loading train car model: %s', tostring(model)))
                    return false
                end
                Wait(10)
            end
        else
            DBG.Warning(string.format('Invalid model for train car index: %d', index))
        end
    end
    return true
end
