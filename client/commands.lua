local Core = exports.vorp_core:GetCore()
local Menu = exports.vorp_menu:GetMenuData()
local MiniGame = exports['bcc-minigames'].initiate()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

-- Key monitoring for train inventory
CreateThread(function()
    local invKey = Config.keys.inventory

    while true do
        Wait(0)

        if IsControlJustPressed(0, invKey) then
            ExecuteCommand('trainInv')
            Wait(500)
        end
    end
end)

RegisterCommand('trainInv', function()
    local isInTrain = IsPedInAnyTrain(PlayerPedId())
    DBG.Info('Open train inventory command triggered. Is in train: ' .. tostring(isInTrain))
    if isInTrain and TrainId and TrainId > 0 then
        TriggerServerEvent('bcc-train:OpenInventory', TrainId)
    else
        DBG.Warning('Cannot open train inventory: not in train or no TrainId')
    end
end, false)

AddEventHandler('playerDropped', function()
    if MyTrain ~= 0 then
        if DoesEntityExist(MyTrain) then
            DeleteEntity(MyTrain)
        end
        MyTrain = 0
    TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false, nil, TrainId, SpawnedStation, nil)
        -- Ensure driving UI state cleared when player drops
        TriggerEvent('bcc-train:DrivingMenuClosed')
    end
end)

RegisterNetEvent('bcc-train:StartLockpick', function(trainId)
    -- Validate trainId parameter
    if not trainId or type(trainId) ~= 'number' then
        DBG.Error(string.format('Invalid trainId provided for lockpick: %s', tostring(trainId)))
        return
    end

    -- Validate config exists
    if not Config.lockPick then
        DBG.Error('Lockpick configuration not found')
        return
    end

    -- Determine degrees based on config
    local degrees = {}
    if Config.lockPick.randomDegrees then

        -- Use random degrees
        degrees = {
            math.random(0, 360),
            math.random(0, 360),
            math.random(0, 360)
        }
    else
        -- Use static degrees from config
        degrees = Config.lockPick.staticDegrees or { 90, 180, 270 } -- Fallback if not configured
    end

    -- Minigame Config
    local cfg = {
        focus = true,                                   -- Should minigame take nui focus
        cursor = true,                                  -- Should minigame have cursor  (required for lockpick)
        maxattempts = Config.lockPick.maxAttempts or 3, -- How many fail attempts are allowed before game over
        threshold = Config.lockPick.difficulty or 20,   -- +- threshold to the stage degree (bigger number means easier)
        hintdelay = Config.lockPick.hintdelay or 100,   -- milliseconds delay on when the circle will shake to show lockpick is in the right position.
        stages = {
            {
                deg = degrees[1] -- 0-360 degrees
            },
            {
                deg = degrees[2] -- 0-360 degrees
            },
            {
                deg = degrees[3] -- 0-360 degrees
            }
        }
    }

    MiniGame.Start('lockpick', cfg, function(result)
        if not result then
            DBG.Error('Lockpick minigame returned nil result')
            Core.NotifyRightTip(_U('pickAttemptFailed'), 4000)
            TriggerServerEvent('bcc-train:ConsumeLockpick')
            return
        end

        local success = (type(result) == 'table' and result.unlocked) or (result == true)
        if success then
            TriggerServerEvent('bcc-train:OpenInventoryAfterLockpick', trainId)
        else
            Core.NotifyRightTip(_U('pickAttemptFailed'), 4000)
            TriggerServerEvent('bcc-train:ConsumeLockpick')
        end
    end)
end)

-- Blow-up Bacchus Bridge
RegisterNetEvent('bcc-train:BridgeFall', function()
    local ran = 0
    local playerCoords = GetEntityCoords(PlayerPedId())

    repeat
        local object = GetRayfireMapObject(playerCoords.x, playerCoords.y, playerCoords.z, 10000.0, 'des_trn3_bridge')
        if object ~= 0 then
            SetStateOfRayfireMapObject(object, 4)
        end

        Wait(100)
        AddExplosion(521.13, 1754.46, 187.65, 28, 1.0, true, false, 0)
        AddExplosion(507.28, 1762.3, 187.77, 28, 1.0, true, false, 0)
        AddExplosion(527.21, 1748.86, 187.8, 28, 1.0, true, false, 0)
        Wait(100)

        if object ~= 0 then
            SetStateOfRayfireMapObject(object, 6) -- SetStateOfRayfireMapObject
        end

        ran = ran + 1
    until ran == 2 --has to run twice no idea why

    --Spawning ghost train model as the game engine wont allow trains to hit each other this will slow the trains down automatically if near the exploded part of the bridge
    Wait(1000)
    local trainHash = joaat('engine_config')
    LoadTrainCars(trainHash, false)                                                                                            -- false = not a preview (ghost train for bridge)
    local ghostTrain = Citizen.InvokeNative(0xc239dbd9a57d2a71, trainHash, 499.69, 1768.78, 188.77, false, false, true,
        false)                                                                                                                 -- CreateMissionTrain

    -- Freeze Train on Spawn
    Citizen.InvokeNative(0xDFBA6BBFF7CCAFBB, ghostTrain, 0.0) -- SetTrainSpeed
    Citizen.InvokeNative(0x01021EB2E96B793C, ghostTrain, 0.0) -- SetTrainCruiseSpeed
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if MyTrain ~= 0 then
        if DoesEntityExist(MyTrain) then
            DeleteEntity(MyTrain)
        end
        MyTrain = 0
        -- Notify server about train cleanup
    TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false, nil, TrainId, SpawnedStation, nil)
        -- Ensure driving UI state cleared during resource stop
        TriggerEvent('bcc-train:DrivingMenuClosed')
    end

    -- Clean up preview train
    if PreviewTrain and DoesEntityExist(PreviewTrain) then
        DeleteEntity(PreviewTrain)
        PreviewTrain = nil
    end

    for _, stationCfg in pairs(Stations) do
        if stationCfg.Blip then
            RemoveBlip(stationCfg.Blip)
            stationCfg.Blip = nil
        end
        if stationCfg.NPC then
            DeleteEntity(stationCfg.NPC)
            stationCfg.NPC = nil
        end
    end

    Menu.CloseAll()
    DestroyAllCams(true)
    DisplayRadar(true)
    TrainShopMenu:Close()

    if DestinationBlip then
        if DoesBlipExist(DestinationBlip) then
            RemoveBlip(DestinationBlip)
        end
        DestinationBlip = nil
    end

    if DeliveryBlip then
        if DoesBlipExist(DeliveryBlip) then
            RemoveBlip(DeliveryBlip)
        end
        DeliveryBlip = nil
    end
end)
