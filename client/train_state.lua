local Core = exports.vorp_core:GetCore()
local Menu = exports.vorp_menu:GetMenuData()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

-- Train Globals (kept as globals for compatibility with existing callers)
MyTrain, TrainId = 0, 0
TrainFuel, TrainCondition = 0, 0
InMenu, InMission = false, false
EngineStarted, ForwardActive, BackwardActive = false, false, false
PreviewTrain = nil
SpawnedStation = nil

-- (Item label RPC/cache removed — delivery flows prefer config-provided labels)

-- Initialize random seed for better math.random usage
math.randomseed(GetGameTimer() + GetRandomIntInRange(1, 1000))

function GetTrainConfig(hash)
    if not hash then
        DBG.Warning('GetTrainConfig called with nil hash')
        return nil
    end

    local config = (Cargo and Cargo[hash]) or
                   (Passenger and Passenger[hash]) or
                   (Mixed and Mixed[hash]) or
                   (Special and Special[hash])

    if not config then
        DBG.Warning(string.format('Train configuration not found for hash: %s', tostring(hash)))
    end

    return config
end
