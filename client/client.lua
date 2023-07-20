CreatedTrain = nil
CreateThread(function()
    SetRandomTrains(false)
    local PromptGroup = VORPutils.Prompts:SetupPromptGroup()
    local firstprompt = PromptGroup:RegisterPrompt(_U("openStationMenu"), 0x760A9C6F, 1, 1, true, 'hold', { timedeventhash = "MEDIUM_TIMED_EVENT" })
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

function spawnTrain(trainTable, dbTable) --credit to rsg_trains for some of the logic here

    local trainHash = joaat(trainTable.model)
    local trainWagons = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash)
	for wagonIndex = 0, trainWagons - 1 do
		local trainWagonModel = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, wagonIndex)
		while not HasModelLoaded(trainWagonModel) do
			Citizen.InvokeNative(0xFA28FE3A6246FC30, trainWagonModel, 1)
			Wait(100)
		end
	end

    local px, py, pz = table.unpack(GetEntityCoords(PlayerPedId()))
	CreatedTrain = Citizen.InvokeNative(0xc239dbd9a57d2a71, trainHash, px, py, pz, false, false, true, false)
    SetTrainSpeed(CreatedTrain, 0.0)
    SetTrainCruiseSpeed(CreatedTrain, 0.0) --these 2 natives freeze train on spawn

	local bliphash = -399496385
	local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, bliphash, CreatedTrain) -- blip for train
	SetBlipScale(blip, 1.5)

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
                TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false)
                RemoveBlip(blip)
                DeleteEntity(CreatedTrain) break
            end
        elseif dist < 10 then
            sleep = false
            if not IsVehicleSeatFree(CreatedTrain, -1) then
                if GetPedInVehicleSeat(CreatedTrain, -1) == PlayerPedId() then
                    if not drivingMenuOpened then
                        drivingMenuOpened = true
                        drivingTrainMenu(trainTable, dbTable)
                    end
                else
                    drivingMenuOpened = false
                    MenuData.CloseAll()
                end
            else
                if drivingMenuOpened then
                    drivingMenuOpened = false
                    MenuData.CloseAll()
                end
            end
        end
        if sleep then
            Wait(1500)
        end
    end
end

--[[ TODO
Multiple locations rhodes, valentine, saint denis (make inventories accessible by all conductors)
Refueling the train (Make take coal item so inv is useful)
Mainting the train (make take oil/items to make inv useful)
Clean the train station (make take cleaning item so inv is useful)
Supply mission (spawn train that has cargo and have it delivered to town only works if no trains are out ofcourse)
Change direction on track on train spawn
Inventory for each individual train(use the moddel + charid to index it)
]]

--[[DONE
Conductor job (done/checking for)
Switching Tracks (Done)
Modifiable Speed ofcourse (Done)
Delete train if the spawned player leaves or is too far away (Done)
Cruise control (Done)
]]