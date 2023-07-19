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
            title = "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; margin-top: 4vh; position:relative; right: 8vh;' src='nui://bcc-train/imgs/trainImg.png'>"
            .. "<div style='position: relative; right: 6vh; margin-top: 4vh;'>" .. _U("trainStation") .. "</div>"
            .. "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; top: -4vh; position: relative; right: -21vh;' src='nui://bcc-train/imgs/trainImg.png'>",
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
            title      = "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; margin-top: 4vh; position:relative; right: 10vh;' src='nui://bcc-train/imgs/trainImg.png'>"
            .. "<div style='position: relative; right: 6vh; margin-top: 4vh;'>" .. _U("trainMenu") .. "</div>"
            .. "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; top: -4vh; position: relative; right: -21vh;' src='nui://bcc-train/imgs/trainImg.png'>",
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

local on = false --used for track switching
function drivingTrainMenu(trainConfigTable)
    MenuData.CloseAll()
    inMenu = false --so this menu doesnt close

    local elements = {
        { label = _U("speed"), value = 0, desc = _U("speed_desc"), type = 'slider', min = 0, max = trainConfigTable.maxSpeed, hop = 1.0 },
        { label = _U("switchTrack"), value = 'switchtrack', desc = _U("switchTrack_desc") }
    }
    if Config.CruiseControl then
        table.insert(elements, { label = _U("forward"), value = 'forward', desc = _U("forward_desc") })
        table.insert(elements, { label = _U("backward"), value = 'backward', desc = _U("backward_desc") })
    end

    local forwardActive, backwardActive, speed = false, false, 0
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title =  "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; margin-top: 4vh; position:relative; right: 7vh;' src='nui://bcc-train/imgs/trainImg.png'>"
            .. "<div style='position: relative; right: 6vh; margin-top: 4vh;'>" .. _U("drivingMenu") .. "</div>"
            .. "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; top: -4vh; position: relative; right: -23vh;' src='nui://bcc-train/imgs/trainImg.png'>",
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
                end,
                ['switchtrack'] = function()
                    local trackModels = {
                        {model = 'FREIGHT_GROUP'},
                        {model = 'TRAINS3'},
                        {model = 'BRAITHWAITES2_TRACK_CONFIG'},
                        {model = 'TRAINS_OLD_WEST01'},
                        {model = 'TRAINS_OLD_WEST03'},
                        {model = 'TRAINS_NB1'},
                        {model = 'TRAINS_INTERSECTION1_ANN'},
                    }
                    if not on then
                        local counter = 0
                        repeat
                            for k, v in pairs(trackModels) do
                                local trackHash = joaat(v.model)
                                Citizen.InvokeNative(0xE6C5E2125EB210C1, trackHash, counter, true)
                            end
                            counter = counter + 1
                        until counter >= 100
                        on = true
                        VORPcore.NotifyRightTip(_U("switchingOn"), 4000)
                    else
                        local counter = 0
                        repeat
                            for k, v in pairs(trackModels) do
                                local trackHash = joaat(v.model)
                                Citizen.InvokeNative(0xE6C5E2125EB210C1, trackHash, counter, false)
                            end
                            counter = counter + 1
                        until counter >= 100
                        on = false
                        VORPcore.NotifyRightTip(_U("switchingOn"), 4000)
                    end
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            else --has to be done this way to get a vector menu option
                speed = data.current.value
                local setMaxSpeed = speed + .1
                if setMaxSpeed > 30.0 then setMaxSpeed = 29.9 end
                Citizen.InvokeNative(0x9F29999DFDF2AEB8, CreatedTrain, setMaxSpeed)
            end
        end)
end


--[[RegisterCommand('trackSwitch', function()
    ------- Functional Track Switching -----------
    if CreatedTrain ~= nil or false then
        local trackModels = {
            {model = 'FREIGHT_GROUP'},
            {model = 'TRAINS3'},
            {model = 'BRAITHWAITES2_TRACK_CONFIG'},
            {model = 'TRAINS_OLD_WEST01'},
            {model = 'TRAINS_OLD_WEST03'},
            {model = 'TRAINS_NB1'},
            {model = 'TRAINS_INTERSECTION1_ANN'},
        }
        if not on then
            local counter = 0
            repeat
                for k, v in pairs(trackModels) do
                    local trackHash = joaat(v.model)
                    Citizen.InvokeNative(0xE6C5E2125EB210C1, trackHash, counter, true)
                end
                counter = counter + 1
            until counter >= 100
            on = true
        else
            local counter = 0
            repeat
                for k, v in pairs(trackModels) do
                    local trackHash = joaat(v.model)
                    Citizen.InvokeNative(0xE6C5E2125EB210C1, trackHash, counter, false)
                end
                counter = counter + 1
            until counter >= 100
            on = false
        end
    end
end)]]