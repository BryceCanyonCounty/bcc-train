CreatedTrain, TrainFuel, TrainId, TrainConfigtable, TrainCondition, TrainBlip = nil, nil, nil, nil, nil, nil
CreateThread(function()
    SetRandomTrains(false)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("openStationMenu"), 0x760A9C6F, 1, 1, true, 'hold',
        { timedeventhash = "MEDIUM_TIMED_EVENT" })
    TriggerServerEvent('bcc-train:ServerBridgeFallHandler', true)
    while true do
        Wait(5)
        local sleep = true
        local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
        for k, v in pairs(Config.Stations) do
            if GetDistanceBetweenCoords(v.coords.x, v.coords.y, v.coords.z, px, py, pz, true) < v.radius then
                sleep = false
                PromptGroup:ShowGroup(_U("trainStation"))
                if firstprompt:HasCompleted() then
                    TriggerServerEvent('bcc-train:JobCheck')
                end
            end
        end
        if sleep then
            Wait(1500)
        end
    end
end)

function spawnTrain(trainTable, dbTable, dirChange) --credit to rsg_trains for some of the logic here
    local trainHash = joaat(trainTable.model)
    local trainWagons = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash)
    TrainFuel = dbTable.fuel
    TrainId = dbTable.trainid
    TrainCondition = dbTable.condition
    TrainConfigtable = trainTable
    for wagonIndex = 0, trainWagons - 1 do
        local trainWagonModel = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, wagonIndex)
        while not HasModelLoaded(trainWagonModel) do
            Citizen.InvokeNative(0xFA28FE3A6246FC30, trainWagonModel, 1)
            Wait(100)
        end
    end

    local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
    CreatedTrain = Citizen.InvokeNative(0xc239dbd9a57d2a71, trainHash, px, py, pz, dirChange, false, true, false)
    SetTrainSpeed(CreatedTrain, 0.0)
    SetTrainCruiseSpeed(CreatedTrain, 0.0) --these 2 natives freeze train on spawn

    local bliphash = -399496385
    TrainBlip = Citizen.InvokeNative(0x23f74c2fda6e7c61, bliphash, CreatedTrain) -- blip for train
    SetBlipScale(TrainBlip, 1.5)
    TriggerEvent('bcc-train:FuelDecreaseHandler')
    TriggerEvent('bcc-train:CondDecreaseHandler')
    TriggerEvent('bcc-train:TrainTargetted') --Triggers the targetting to fuel and repair etc (DAM CONFOOOSIN THIS SHIT IS)

    local drivingMenuOpened = false
    while DoesEntityExist(CreatedTrain) do --done to check if it has been deleted via the command
        Wait(5)
        local px2, py2, pz2 = table.unpack(GetEntityCoords(PlayerPedId()))
        local cx, cy, cz = table.unpack(GetEntityCoords(CreatedTrain))
        local sleep = true
        local dist = GetDistanceBetweenCoords(px2, py2, pz2, cx, cy, cz, true)
        if dist > 50 then
            sleep = false
            if dist > Config.TrainDespawnDist then
                VORPcore.NotifyRightTip(_U("tooFarFromTrain"), 4000)
                TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false, CreatedTrain)
                RemoveBlip(TrainBlip)
                MenuData.CloseAll()
                DeleteEntity(CreatedTrain)
                break
            end
        elseif dist < 10 then
            sleep = false
            if not IsVehicleSeatFree(CreatedTrain, -1) then
                if GetPedInVehicleSeat(CreatedTrain, -1) == PlayerPedId() then
                    if not drivingMenuOpened then
                        drivingMenuOpened = true
                        drivingTrainMenu(trainTable, dbTable)
                        showHUD(TrainCondition, trainTable.maxCondition, TrainFuel, trainTable.maxFuel)
                    end
                else
                    drivingMenuOpened = false
                    MenuData.CloseAll()
                    hideHUD()
                end
            else
                if drivingMenuOpened then
                    drivingMenuOpened = false
                    MenuData.CloseAll()
                    hideHUD()
                end
            end
        end
        if sleep then
            Wait(1500)
        end
    end
end

AddEventHandler('bcc-train:FuelDecreaseHandler', function()
    while DoesEntityExist(CreatedTrain) do
        Wait(5)
        if EngineStarted then
            if TrainFuel > 0 then
                Wait(Config.FuelSettings.FuelDecreaseTime)
                TriggerServerEvent('bcc-train:DecTrainFuel', TrainId, TrainFuel)
                Wait(1000)
            else
                Citizen.InvokeNative(0x9F29999DFDF2AEB8, CreatedTrain, 0.0)
            end
        else
            Citizen.InvokeNative(0x9F29999DFDF2AEB8, CreatedTrain, 0.0)
        end
    end
end)

AddEventHandler('bcc-train:CondDecreaseHandler', function()
    while DoesEntityExist(CreatedTrain) do
        Wait(5)
        if EngineStarted then
            if TrainCondition > 0 then
                Wait(Config.ConditionSettings.CondDecreaseTime)
                TriggerServerEvent('bcc-train:DecTrainCond', TrainId, TrainCondition)
                Wait(1000)
            else
                Citizen.InvokeNative(0x9F29999DFDF2AEB8, CreatedTrain, 0.0)
            end
        end
    end
end)

RegisterNetEvent('bcc-train:CleintFuelUpdate', function(fuel)
    TrainFuel = fuel
    updateHUD(nil, fuel)
end)

RegisterNetEvent('bcc-train:CleintCondUpdate', function(cond)
    TrainCondition = cond
    updateHUD(cond, nil)
end)

--------- Bacchus bridge collapse handling --------
RegisterNetEvent("bcc-train:BridgeFall", function()
    local ran = 0
    repeat
        local object = GetRayfireMapObject(GetEntityCoords(PlayerPedId()), 10000.0, 'des_trn3_bridge')
        SetStateOfRayfireMapObject(object, 4)
        Wait(100)
        AddExplosion(521.13, 1754.46, 187.65, 28, 1.0, true, false, true)
        AddExplosion(507.28, 1762.3, 187.77, 28, 1.0, true, false, true)
        AddExplosion(527.21, 1748.86, 187.8, 28, 1.0, true, false, true)
        Wait(100)
        SetStateOfRayfireMapObject(object, 6)
        ran = ran + 1
    until ran == 2 --has to run twice no idea why

    --Spawning ghost train model as the game engine wont allow trains to hit each other this will slow the trains down automatically if near the exploded part of the bridge
    Wait(1000)
    local trainHash = joaat('ghost_train_config')
    local trainWagons = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash)
    for wagonIndex = 0, trainWagons - 1 do
        local trainWagonModel = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, wagonIndex)
        while not HasModelLoaded(trainWagonModel) do
            Citizen.InvokeNative(0xFA28FE3A6246FC30, trainWagonModel, 1)
            Wait(100)
        end
    end
    local ghostTrain = Citizen.InvokeNative(0xc239dbd9a57d2a71, trainHash, 489.65, 1770.44, 187.67, false, false, true, false)
    SetTrainSpeed(ghostTrain, 0.0)
    SetTrainCruiseSpeed(ghostTrain, 0.0) --these 2 natives freeze train on spawn
    SetEntityVisible(ghostTrain, false)
    SetEntityCollision(ghostTrain, false, false)
end)

CreateThread(function()
    if Config.BacchusBridgeDestroying.enabled then
        local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
        local firstprompt = PromptGroup:RegisterPrompt(_U("blowUpBridge"), 0x760A9C6F, 1, 1, true, 'hold',
            { timedeventhash = "MEDIUM_TIMED_EVENT" })
        while true do
            local sleep = true
            local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
            if GetDistanceBetweenCoords(px, py, pz, Config.BacchusBridgeDestroying.coords.x, Config.BacchusBridgeDestroying.coords.y, Config.BacchusBridgeDestroying.coords.z, true) < 2 then
                sleep = false
                PromptGroup:ShowGroup("")
                if firstprompt:HasCompleted() then
                    TriggerServerEvent('bcc-train:ServerBridgeFallHandler', false)
                end
            end

            if sleep then
                Wait(1500)
            end
            Wait(5)
        end
    end
end)

function deliveryMission()
    local dCoords = Config.SupplyDeliveryLocations[math.random(1, #Config.SupplyDeliveryLocations)]
    local blip = Citizen.InvokeNative(0x45F13B7E0A15C880, -1282792512, dCoords.coords.x, dCoords.coords.y,
        dCoords.coords.z, 10.0)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, _U("deliverySpot"))

    VORPcore.NotifyRightTip(_U("goToDeliverSpot"), 4000)
    local beenIn = false
    while true do
        Wait(5)
        if IsEntityDead(PlayerPedId()) or not DoesEntityExist(CreatedTrain) then break end
        local sleep = true
        local tx, ty, tz = table.unpack(GetEntityCoords(CreatedTrain))
        local dist = GetDistanceBetweenCoords(dCoords.coords.x, dCoords.coords.y, dCoords.coords.z, tx, ty, tz, true)
        if dist < dCoords.radius + 300 then
            sleep = false
            if dist < dCoords.radius then
                beenIn = true
                VORPcore.NotifyRightTip(_U("goDeliver"), 4000)
                local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
                if GetDistanceBetweenCoords(px, py, pz, dCoords.coords.x, dCoords.coords.y, dCoords.coords.z, true) < 2 then
                    InMission = false
                    RemoveBlip(blip)
                    VORPcore.NotifyRightTip(_U("deliveryDone") .. dCoords.pay, 4000)
                    TriggerServerEvent('bcc-train:DeliveryPay', dCoords.pay)
                    break
                end
            end
            if beenIn and dist > dCoords.radius then
                beenIn = false
                VORPcore.NotifyRightTip(_U("trainToFar"), 4000)
            end
        end

        if sleep then
            Wait(1500)
        end
    end
    if IsEntityDead(PlayerPedId()) or not DoesEntityExist(CreatedTrain) then
        DeleteEntity(CreatedTrain)
        InMission = false
        VORPcore.NotifyRightTip(_U("missionFailed"), 4000)
    end
end

local blips = {}
CreateThread(function()
    for k, v in pairs(Config.Stations) do
        local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords.x, v.coords.y, v.coords.z) -- This create a blip with a defualt blip hash we given
        SetBlipSprite(blip, Config.StationBlipHash, 1) -- This sets the blip hash to the given in config.
        SetBlipScale(blip, 0.8)
        Citizen.InvokeNative(0x662D364ABF16DE2F, blip, joaat(Config.StationBlipColor))
        Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.stationName) -- Sets the blip Name
        table.insert(blips, blip)
    end
end)

------- Cleanup -----
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if DoesEntityExist(CreatedTrain) then
            DeleteEntity(CreatedTrain)
            hideHUD()
        end
        if #blips > 0 then
            for key, value in pairs(blips) do
                RemoveBlip(value)
            end
        end
    end
end)
AddEventHandler("playerDropped", function ()
    if DoesEntityExist(CreatedTrain) then
        DeleteEntity(CreatedTrain)
        TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false)
    end
end)

--[[
    Sacred Comment Penis
    8========================D
    Do not touch
]]