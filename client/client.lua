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

function spawnTrain(trainTable) --credit to rsg_trains for some of the logic here

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
	local createdTrain = Citizen.InvokeNative(0xc239dbd9a57d2a71, trainHash, px, py, pz, false, false, true, false)
    SetTrainSpeed(createdTrain, 0.0)
    SetTrainCruiseSpeed(createdTrain, 0.0) --these 2 natives freeze train on spawn



	local bliphash = -399496385
	local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, bliphash, createdTrain) -- blip for train
	SetBlipScale(blip, 1.5)
end

--[[
Conductor job (done/checking for)
Multiple locations rhodes, valentine, saint denis (make inventories accessible by all conductors)
Switching Tracks
Modifiable Speed ofcourse
Refueling the train (Make take coal item so inv is useful)
Mainting the train (make take oil/items to make inv useful)
Clean the train station (make take cleaning item so inv is useful)
Supply mission (spawn train that has cargo and have it delivered to town only works if no trains are out ofcourse)
Delete train if the spawned player leaves or is too far away
Cruise control
]]