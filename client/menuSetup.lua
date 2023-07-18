----- Close Menu When Backspaced Out -----
local inMenu = false

AddEventHandler('bcc-train:MenuClose', function()
    while inMenu do
        Wait(5)
        if IsControlJustReleased(0, 0x156F7119) then
            inMenu = false
            MenuData.CloseAll() break
        end
    end
end)

RegisterNetEvent('bcc-train:MainStationMenu', function()
    inMenu = true
    TriggerEvent('bcc-train:MenuClose')
    MenuData.CloseAll()

    local elements = {
        { label = _U("spawnTrain"),         value = 'spawntrain',    desc = _U("spawnTrain_desc") }
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("trainStation"),
            align = 'top-left',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local selectedOption = {
                ['spawntrain'] = function()
                    VORPcore.RpcCall("bcc-train:AllowTrainSpawn", function(result)
                        if result then
                            chooseTrainMenu()
                        else
                           VORPcore.NotifyRightTip(_U("trainSpawnedAlrady"), 4000)
                        end
                    end)
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end)

function chooseTrainMenu()
    MenuData.CloseAll()
    local elements = {}

    for k, trainInfo in pairs(Config.Trains) do
        elements[#elements + 1] = {
            label = _U("trainModel") .. ' ' .. trainInfo.model,
            value = "train" .. k,
            desc = "",
            info = trainInfo
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("trainMenu"),
            subtext    = _U("trainMenu_desc"),
            align      = 'top-left',
            elements   = elements,
            itemHeight = "4vh"
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                VORPcore.NotifyRightTip(_U("trainSpawned"), 4000)
                TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', true)
                MenuData.CloseAll() --have to be called above funct
                spawnTrain(data.current.info)
            end
        end)
end

function drivingTrainMenu(trainConfigTable)
    MenuData.CloseAll()
    inMenu = false --so this menu doesnt close

    local elements = {
        { label = _U("speed"), value = 0, desc = _U("speed_desc"), type = 'slider', min = 0, max = trainConfigTable.maxSpeed, hop = 1.0 },
        { label = _U("forward"), value = 'forward', desc = _U("forward_desc") },
        { label = _U("backward"), value = 'backward', desc = _U("backward_desc") }
    }

    local speed
    local forwardActive, backwardActive = false, false
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("trainStation"),
            align = 'top-left',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local selectedOption = {
                ['forward'] = function()
                    if not backwardActive then
                        if not forwardActive then
                            forwardActive = true
                            VORPcore.NotifyRightTip(_U("forwardEnabled"), 4000)
                            while forwardActive do
                                Wait(100)
                                if speed ~= 0 and speed ~= nil then --stops error
                                    SetTrainSpeed(CreatedTrain, speed + .1)
                                end
                            end
                        else
                            VORPcore.NotifyRightTip(_U("forwardDisbaled"), 4000)
                            forwardActive = false
                        end
                    else
                        VORPcore.NotifyRightTip(_U("backwardsIsOn"), 4000)
                    end
                end,
                ['backward'] = function()
                    if not forwardActive then
                        if not backwardActive then
                            backwardActive = true
                            VORPcore.NotifyRightTip(_U("backwardEnabled"), 4000)
                            while backwardActive do
                                Wait(100)
                                if speed ~= 0 and speed ~= nil then --stops error
                                    SetTrainSpeed(CreatedTrain, speed + .1 - speed * 2)
                                end
                            end
                        else
                            VORPcore.NotifyRightTip(_U("backwardDisabled"), 4000)
                            backwardActive = false
                        end
                    else
                        VORPcore.NotifyRightTip(_U("forwardsIsOn"), 4000)
                    end
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            else --has to be done this way to get a vector menu option
                speed = data.current.value
            end
        end)
end