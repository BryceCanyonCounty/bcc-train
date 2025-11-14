local Core = exports.vorp_core:GetCore()
local Menu = exports.vorp_menu:GetMenuData()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

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

    Menu.CloseAll()
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
        print('Station config not found for:', station)
        return nil
    end

    local spawnCoords = nil
    if stationCfg.train and stationCfg.train.coords then
        spawnCoords = stationCfg.train.coords
    end

    if not spawnCoords then
        print('No spawn coordinates found for station:', station)
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
        print('Train creation failed or entity does not exist')
    end

    return nil
end
