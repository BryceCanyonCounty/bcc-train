----- Close Menu When Backspaced Out -----
local inMenu = false
EngineStarted = false

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
        { label = _U("ownedTrains"), value = 'ownedtrains', desc = _U("ownedTrains_desc") },
        { label = _U("buyTrains"), value = 'buytrains', desc = _U("buyTrains_desc") }
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
                ['ownedtrains'] = function()
                    MenuData.CloseAll()
                    TriggerServerEvent('bcc-train:GetOwnedTrains', 'viewOwned')
                end,
                ['buytrains'] = function()
                    MenuData.CloseAll()
                    TriggerServerEvent('bcc-train:GetOwnedTrains', 'buyTrain')
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end)

RegisterNetEvent('bcc-train:BuyTrainMenu', function(ownedTrains)
    MenuData.CloseAll()
    local elements = {}
    if #ownedTrains <= 0 then
        for k, v in pairs(Config.Trains) do
            elements[#elements + 1] = {
                label = _U("trainModel") .. ' ' .. v.model .. ' ' .. _U("price") .. v.cost,
                value = "train" .. k,
                desc = "",
                info = v
            }
        end
    else
        for key, value in pairs(Config.Trains) do
            local insert = true
            for k, v in pairs(ownedTrains) do
                if value.model == v.trainModel then
                    insert = false
                end
            end
            if insert then
                elements[#elements + 1] = {
                    label = _U("trainModel") .. ' ' .. value.model .. ' ' .. _U("price") .. value.cost,
                    value = "train" .. key,
                    desc = "",
                    info = value
                }
            end
        end
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
                MenuData.CloseAll()
                TriggerServerEvent('bcc-train:BoughtTrainHandler', data.current.info)
            end
        end)
end)

RegisterNetEvent('bcc-train:OwnedTrainsMenu', function(ownedTrains)
    MenuData.CloseAll()
    local elements = {}
    if #ownedTrains <= 0 then
        VORPcore.NotifyRightTip(_U("noOwnedTrains"), 4000)
    else
        for key, value in pairs(ownedTrains) do
            elements[#elements + 1] = {
                label = _U("trainModel") .. ' ' .. value.trainModel,
                value = "train" .. key,
                desc = "",
                info = value
            }
        end
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
                VORPcore.RpcCall("bcc-train:AllowTrainSpawn", function(result)
                    if result then
                        VORPcore.NotifyRightTip(_U("trainSpawned"), 4000)
                        TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', true)
                        MenuData.CloseAll() --have to be called above funct
                        local configTable = nil
                        for k, v in pairs(Config.Trains) do
                            if data.current.info.trainModel == v.model then
                                configTable = v break
                            end
                        end
                        spawnTrain(configTable, data.current.info)
                    else
                       VORPcore.NotifyRightTip(_U("trainSpawnedAlrady"), 4000)
                    end
                end)
            end
        end)
end)

local on = false --used for track switching
function drivingTrainMenu(trainConfigTable, trainDbTable)
    MenuData.CloseAll()
    inMenu = false --so this menu doesnt close

    local elements = {
        { label = _U("speed"), value = 0, desc = _U("speed_desc"), type = 'slider', min = 0, max = trainConfigTable.maxSpeed, hop = 1.0 },
        { label = _U("switchTrack"), value = 'switchtrack', desc = _U("switchTrack_desc") },
        { label = _U("checkFuel"), value = 'checkFuel', desc = _U("checkFuel_desc") },
        { label = _U("addFuel"), value = 'addFuel', desc = _U("addFuel_desc") },
        { label = _U("checkCond"), value = 'checkCond', desc = _U("checkCond_desc") },
        { label = _U("repairdTrain"), value = 'repairTrain', desc = _U("repairdTrain_desc") },
        { label = _U("startEnging"), value = 'startEngine', desc = _U("startEnging_desc") },
        { label = _U("stopEngine"), value = 'stopEngine', desc = _U("stopEngine_desc") }
    }
    if Config.CruiseControl then
        table.insert(elements, { label = _U("forward"), value = 'forward', desc = _U("forward_desc") })
        table.insert(elements, { label = _U("backward"), value = 'backward', desc = _U("backward_desc") })
    end
    if trainConfigTable.allowInventory then
        table.insert(elements, { label = _U("openInv"), value = 'openInv', desc = _U("openInv_desc") })
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
                    if EngineStarted then
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
                    end
                end,
                ['backward'] = function()
                    if EngineStarted then
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
                end,
                ['openInv'] = function()
                    TriggerServerEvent('bcc-train:OpenTrainInv', trainDbTable.trainid)
                end,
                ['checkFuel'] = function()
                    TriggerServerEvent('bcc-train:CheckTrainFuel', TrainId, TrainConfigtable)
                end,
                ['addFuel'] = function()
                    TriggerServerEvent('bcc-train:FuelTrain', TrainId, TrainConfigtable)
                end,
                ['stopEngine'] = function()
                    VORPcore.NotifyRightTip(_U("engineStopped"), 4000)
                    EngineStarted = false
                    Citizen.InvokeNative(0x9F29999DFDF2AEB8, CreatedTrain, 0.0)
                end,
                ['startEngine'] = function()
                    VORPcore.NotifyRightTip(_U("engineStarted"), 4000)
                    EngineStarted = true
                    maxSpeedCalc(speed)
                end,
                ['checkCond'] = function()
                    TriggerServerEvent('bcc-train:CheckTrainCond', TrainId, TrainConfigtable)
                end,
                ['repairTrain'] = function()
                    TriggerServerEvent('bcc-train:RepairTrain', TrainId, TrainConfigtable)
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            else --has to be done this way to get a vector menu option
                speed = data.current.value
                maxSpeedCalc(speed)
            end
        end)
end

function maxSpeedCalc(speed)
    local setMaxSpeed = speed + .1
    if setMaxSpeed > 30.0 then setMaxSpeed = 29.9 end
    Citizen.InvokeNative(0x9F29999DFDF2AEB8, CreatedTrain, setMaxSpeed)
end