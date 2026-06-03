-- Client initialization: core setup, global state, and helper functions

Core = exports.vorp_core:GetCore()
BccUtils = exports['bcc-utils'].initiate()
FeatherMenu = exports['feather-menu'].initiate()
VorpMenu = exports.vorp_menu:GetMenuData() -- (Driving Menu Only)
MiniGame = exports['bcc-minigames'].initiate()
DBG = BccUtils.Debug:Get('bcc-train', Config.devMode.active)

if DBG then
    DBG:Enable()
    DBG:Info('Train debug initialized')
end

-- Train global state
MyTrain, TrainId = 0, 0
TrainFuel, TrainCondition = 0, 0
InMenu, InMission = false, false
EngineStarted, ForwardActive, BackwardActive = false, false, false
PreviewTrain = nil
SpawnedStation = nil

-- Initialize random seed for better math.random usage
math.randomseed(GetGameTimer() + GetRandomIntInRange(1, 1000))

-- Get train configuration by hash from all categories
function GetTrainConfig(hash)
    if not hash then
        DBG:Warning('GetTrainConfig called with nil hash')
        return nil
    end

    local config = (Cargo and Cargo[hash]) or
                   (Passenger and Passenger[hash]) or
                   (Mixed and Mixed[hash]) or
                   (Special and Special[hash])

    if not config then
        DBG:Warning(string.format('Train configuration not found for hash: %s', tostring(hash)))
    end

    return config
end

function LoadModel(model, modelName)
    if not IsModelValid(model) then
        return print('Invalid model:', modelName)
    end

    if not HasModelLoaded(model) then
        RequestModel(model, false)

        local timeout = 10000
        local startTime = GetGameTimer()

        while not HasModelLoaded(model) do
            if GetGameTimer() - startTime > timeout then
                print('Failed to load model:', modelName)
                return
            end
            Wait(10)
        end
    end
end
