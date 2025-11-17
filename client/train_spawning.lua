-- Train spawning logic: spawn, reset, and preview train management

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

AddEventHandler('bcc-train:ResetTrain', function()
    if MyTrain ~= 0 then
        if DoesEntityExist(MyTrain) then
            DeleteEntity(MyTrain)
        end
        MyTrain = 0
    end

    if InMission then
        Core.NotifyRightTip(_U('missionFailed'), 4000)
        InMission = false
    end

    VorpMenu.CloseAll()
    EngineStarted = false
    ForwardActive = false
    BackwardActive = false

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

    TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false, nil, TrainId, SpawnedStation, nil)
    SpawnedStation = nil -- Reset the spawned station
    -- Notify local clients to clear driving menu state (keeps DrivingMenuOpened in sync)
    TriggerEvent('bcc-train:DrivingMenuClosed')
end)

function DeletePreviewTrain()
    if PreviewTrain and DoesEntityExist(PreviewTrain) then
        DeleteEntity(PreviewTrain)
        PreviewTrain = nil
        Wait(100)
    end
end

function SpawnPreviewTrainWithDirection(hash, station, direction)
    local stationCfg = Stations[station]
    if not stationCfg then
        DBG.Warning('Station config not found for: ' .. tostring(station))
        return nil
    end

    local spawnCoords = nil
    if stationCfg.train and stationCfg.train.coords then
        spawnCoords = stationCfg.train.coords
    end

    if not spawnCoords then
        DBG.Warning('No spawn coordinates found for station: ' .. tostring(station))
        return nil
    end

    LoadTrainCars(hash, true) -- true = isPreview
    -- Use direction parameter (true = reverse, false = normal)
    local train = CreateMissionTrain(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, direction, false, true, false)

    SetTrainSpeed(train, 0.0)
    SetTrainCruiseSpeed(train, 0.0)

    if train and DoesEntityExist(train) then
        return train
    else
        DBG.Warning('Train creation failed or entity does not exist')
    end

    return nil
end

function SpawnTrain(myTrainData, trainCfg, direction, station) --credit to rsg_trains for some of the logic here
    -- Validate parameters
    if not trainCfg or not myTrainData then
        DBG.Error('Invalid parameters provided to SpawnTrain')
        return
    end

    -- Use the train model from database - this should be a hex hash after migration
    local modelToSpawn = myTrainData.trainModel
    if not modelToSpawn then
        DBG.Error('No train model available in database record')
        return
    end

    -- Convert hex hash to numeric for spawning
    local hash = tonumber(modelToSpawn)
    if not hash then
        DBG.Error(string.format('Failed to convert hex hash to numeric: %s', tostring(modelToSpawn)))
        return
    end

    TrainFuel = tonumber(myTrainData.fuel) or 0
    TrainCondition = tonumber(myTrainData.condition) or 0
    TrainId = tonumber(myTrainData.trainid) or 0
    SpawnedStation = station -- Track which station this train was spawned from

    if TrainId == 0 then
        DBG.Error('Invalid train ID provided')
        return
    end

    LoadTrainCars(hash, false) -- false = not a preview
    local coords = Stations[station].train.coords
    local conductor = false    -- Set to true if you want an AI conductor to be present (set speed once)
    local passengers = false   -- Set to true if you want AI passengers to be present (untested)
    MyTrain = CreateMissionTrain(hash, coords.x, coords.y, coords.z, direction, passengers, true, conductor)

    if MyTrain == 0 then
        DBG.Error('Failed to create train entity')
        return
    end

    SetModelAsNoLongerNeeded(hash)
    -- Freeze Train on Spawn
    SetTrainSpeed(MyTrain, 0.0)
    SetTrainCruiseSpeed(MyTrain, 0.0)

    local netId = NetworkGetNetworkIdFromEntity(MyTrain)
    local spawnCoords = GetEntityCoords(MyTrain)
    TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', true, netId, TrainId, station, spawnCoords)

    if trainCfg.blip.show then
        local trainBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1749618580, MyTrain)                   -- BlipAddForEntity
        SetBlipSprite(trainBlip, joaat(trainCfg.blip.sprite), true)
        Citizen.InvokeNative(0x9CB1A1623062F402, trainBlip, trainCfg.blip.name)                            -- SetBlipNameFromPlayerString
        Citizen.InvokeNative(0x662D364ABF16DE2F, trainBlip, joaat(Config.BlipColors[trainCfg.blip.color])) -- BlipAddModifier
    end

    if trainCfg.inventory.enabled then
        TriggerServerEvent('bcc-train:RegisterInventory', TrainId, modelToSpawn)
    end

    if trainCfg.gamerTag.enabled then
        TriggerEvent('bcc-train:TrainTag', trainCfg, myTrainData)
    end

    if trainCfg.steamer and trainCfg.fuel.enabled then
        TriggerEvent('bcc-train:FuelDecreaseHandler', trainCfg, myTrainData)
    end

    if trainCfg.condition.enabled then
        TriggerEvent('bcc-train:CondDecreaseHandler', trainCfg, myTrainData)
    end

    TriggerEvent('bcc-train:TrainHandler', trainCfg, myTrainData)

    if Config.seated then
        DoScreenFadeOut(500)
        Wait(500)
        SetPedIntoVehicle(PlayerPedId(), MyTrain, -1)
        Wait(500)
        DoScreenFadeIn(500)
    end
end
