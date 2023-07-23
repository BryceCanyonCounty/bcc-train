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
                        print(trainTable.maxCondition)
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

------- Cleanup -----
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        if DoesEntityExist(CreatedTrain) then
            DeleteEntity(CreatedTrain)
            hideHUD()
        end
    end
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
    local trainHash = joaat('appleseed_config')
    local trainWagons = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash)
    for wagonIndex = 0, trainWagons - 1 do
        local trainWagonModel = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, wagonIndex)
        while not HasModelLoaded(trainWagonModel) do
            Citizen.InvokeNative(0xFA28FE3A6246FC30, trainWagonModel, 1)
            Wait(100)
        end
        --SetEntityCollision(trainWagonModel, false, false)
    end
    local ghostTrain = Citizen.InvokeNative(0xc239dbd9a57d2a71, trainHash, 489.65, 1770.44, 187.67, false, false, true,
        false)
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

--[[ TODO
- Skill checks
]]

--[[DONE
- Conductor job (done/checking for)
- Switching Tracks (Done)
- Modifiable Speed ofcourse (Done)
- Delete train if the spawned player leaves or is too far away (Done)
- Cruise control (Done)
- Inventory for each individual train(done)
- Export to check if a train is out for other scripts(done)
- Refueling the train (Make take coal item so inv is useful) (Done)
- Webhooking(Done)
- Mainting the train (make take oil/items to make inv useful) (Done)
- Multiple locations rhodes, valentine, saint denis (make inventories accessible by all conductors) (Done)
- Export to return the train entity to be used in code (Done)
- Change direction on track on train spawn (Done)
- Investigate this working on the western/armadillo rails (Done/Works)
- Option in train driving menu to delete train (Done)
- Make the big bridge explodeable using rayfire thnx to jannings sync it and make trains stop before it reaches the bridge if blown(also make export for other scripts to see if its blown or not investigate spawning a ghost train on the tracks there to make trains stop (trains wont hit other trains and the game engine stops them automatically to prevent it)) (Done)
- Export to see get distance between train and a coord (Not Needed existing export returns entity just do getent coords)
- Supply mission (spawn train that has cargo and have it delivered to town only works if no trains are out ofcourse(Export to see if in progress)) (Done)
]]

--[[ DOLATER
- Clean the train station (make take cleaning item so inv is useful) (Do Later)
]]

--[[
    Sacred Comment Penis
    8========================D
    Do not touch
]]
