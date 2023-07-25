----- Close Menu When Backspaced Out -----
local inMenu, InMission = false, false
EngineStarted = false

AddEventHandler('bcc-train:MenuClose', function()
    while inMenu do
        Wait(5)
        if IsControlJustReleased(0, 0x156F7119) then
            inMenu = false
            MenuData.CloseAll()
            break
        end
    end
end)

RegisterNetEvent('bcc-train:MainStationMenu', function()
    inMenu = true
    TriggerEvent('bcc-train:MenuClose')
    MenuData.CloseAll()

    local elements = {
        { label = _U("ownedTrains"),     value = 'ownedtrains',     desc = _U("ownedTrains_desc") },
        { label = _U("buyTrains"),       value = 'buytrains',       desc = _U("buyTrains_desc") },
        { label = _U("deliveryMission"), value = 'deliveryMission', desc = _U("deliveryMission_desc") }
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title =
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; margin-top: 4vh; position:relative; right: 8vh;' src='nui://bcc-train/imgs/trainImg.png'>"
                .. "<div style='position: relative; right: 6vh; margin-top: 4vh;'>" .. _U("trainStation") .. "</div>"
                ..
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; top: -4vh; position: relative; right: -21vh;' src='nui://bcc-train/imgs/trainImg.png'>",
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
                end,
                ['deliveryMission'] = function()
                    if CreatedTrain ~= nil then
                        if not InMission then
                            InMission = true
                            deliveryMission()
                        else
                            VORPcore.NotifyRightTip(_U("inMission"), 4000)
                        end
                    else
                        VORPcore.NotifyRightTip(_U("noTrain"), 4000)
                    end
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
            title      =
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; margin-top: 4vh; position:relative; right: 10vh;' src='nui://bcc-train/imgs/trainImg.png'>"
                .. "<div style='position: relative; right: 6vh; margin-top: 4vh;'>" .. _U("trainMenu") .. "</div>"
                ..
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; top: -4vh; position: relative; right: -21vh;' src='nui://bcc-train/imgs/trainImg.png'>",
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
            title      =
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; margin-top: 4vh; position:relative; right: 10vh;' src='nui://bcc-train/imgs/trainImg.png'>"
                .. "<div style='position: relative; right: 6vh; margin-top: 4vh;'>" .. _U("trainMenu") .. "</div>"
                ..
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; top: -4vh; position: relative; right: -21vh;' src='nui://bcc-train/imgs/trainImg.png'>",
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
                        TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', true)
                        MenuData.CloseAll() --have to be called above funct
                        local configTable = nil
                        for k, v in pairs(Config.Trains) do
                            if data.current.info.trainModel == v.model then
                                configTable = v
                                break
                            end
                        end
                        switchDirectionMenu(configTable, data.current.info)
                    else
                        VORPcore.NotifyRightTip(_U("trainSpawnedAlrady"), 4000)
                    end
                end)
            end
        end)
end)

function switchDirectionMenu(configTable, menuTable)
    MenuData.CloseAll()
    inMenu = false

    local elements = {
        { label = _U("changeSpawnDir"),   value = 'changeSpawnDir',   desc = _U("changeSpawnDir_desc") },
        { label = _U("noChangeSpawnDir"), value = 'noChangeSpawnDir', desc = _U("noChangeSpawnDir_desc") }
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      =
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; margin-top: 4vh; position:relative; right: 10vh;' src='nui://bcc-train/imgs/trainImg.png'>"
                .. "<div style='position: relative; right: 6vh; margin-top: 4vh;'>" .. _U("trainMenu") .. "</div>"
                ..
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; top: -4vh; position: relative; right: -21vh;' src='nui://bcc-train/imgs/trainImg.png'>",
            subtext    = _U("trainMenu_desc"),
            align      = 'top-left',
            elements   = elements,
            itemHeight = "4vh"
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value == 'changeSpawnDir' then
                MenuData.CloseAll()
                VORPcore.NotifyRightTip(_U("trainSpawned"), 4000)
                spawnTrain(configTable, menuTable, true)
            else
                MenuData.CloseAll()
                VORPcore.NotifyRightTip(_U("trainSpawned"), 4000)
                spawnTrain(configTable, menuTable, false)
            end
        end)
end

local on, speed = false, 0 --used for track switching
function drivingTrainMenu(trainConfigTable, trainDbTable)
    MenuData.CloseAll()
    inMenu = false --so this menu doesnt close

    local elements = {
        {
            label = _U("speed"),
            value = speed,
            desc = _U("speed_desc"),
            type = 'slider',
            min = 0,
            max =
                trainConfigTable.maxSpeed,
            hop = 1.0
        },
        { label = _U("switchTrack"),  value = 'switchtrack', desc = _U("switchTrack_desc") },
    }
    if Config.CruiseControl then
        table.insert(elements, { label = _U("forward"), value = 'forward', desc = _U("forward_desc") })
        table.insert(elements, { label = _U("backward"), value = 'backward', desc = _U("backward_desc") })
    end
    if EngineStarted then
        table.insert(elements, { label = _U("stopEngine"),   value = 'stopEngine',  desc = _U("stopEngine_desc") })
    else
        table.insert(elements, { label = _U("startEnging"),  value = 'startEngine', desc = _U("startEnging_desc") })
    end
    if trainConfigTable.allowInventory then
        table.insert(elements, { label = _U("openInv"), value = 'openInv', desc = _U("openInv_desc") })
    end

    table.insert(elements, { label = _U("deleteTrain"), value = 'deleteTrain', desc = _U("deleteTrain_desc") }) --done here to ensure this is at the bottom of menu

    local forwardActive, backwardActive = false, false
    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title =
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; margin-top: 4vh; position:relative; right: 7vh;' src='nui://bcc-train/imgs/trainImg.png'>"
                .. "<div style='position: relative; right: 6vh; margin-top: 4vh;'>" .. _U("drivingMenu") .. "</div>"
                ..
                "<img style='max-height:5vh;max-width:7vh; float: left;text-align: center; top: -4vh; position: relative; right: -23vh;' src='nui://bcc-train/imgs/trainImg.png'>",
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
                                if TrainFuel ~= 0 then
                                    forwardActive = true
                                    VORPcore.NotifyRightTip(_U("forwardEnabled"), 4000)
                                    while forwardActive do
                                        Wait(100)
                                        local cx, cy, cz = GetEntityCoords(CreatedTrain)
                                        if GetDistanceBetweenCoords(517.56, 1757.27, 188.34, cx, cy, cz) < 1000 then
                                            VORPcore.NotifyRightTip(_U("cruiseDisabledInRegion"), 4000)
                                            forwardActive = false break
                                        end
                                        if speed ~= 0 and speed ~= nil then --stops error
                                            SetTrainSpeed(CreatedTrain, speed + .1)
                                        end
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("noCruiseNoFuel"), 4000)
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
                                if TrainFuel ~= 0 then
                                    backwardActive = true
                                    VORPcore.NotifyRightTip(_U("backwardEnabled"), 4000)
                                    while backwardActive do
                                        Wait(100)
                                        local cx, cy, cz = GetEntityCoords(CreatedTrain)
                                        if GetDistanceBetweenCoords(517.56, 1757.27, 188.34, cx, cy, cz) < 1000 then
                                            VORPcore.NotifyRightTip(_U("cruiseDisabledInRegion"), 4000)
                                            backwardActive = false break
                                        end
                                        if speed ~= 0 and speed ~= nil then --stops error
                                            SetTrainSpeed(CreatedTrain, speed + .1 - speed * 2)
                                        end
                                    end
                                else
                                    VORPcore.NotifyRightTip(_U("noCruiseNoFuel"), 4000)
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
                    if not on then
                        trackSwitch(true)
                        on = true
                        VORPcore.NotifyRightTip(_U("switchingOn"), 4000)
                    else
                        trackSwitch(false)
                        on = false
                        VORPcore.NotifyRightTip(_U("switchingOn"), 4000)
                    end
                end,
                ['openInv'] = function()
                    TriggerServerEvent('bcc-train:OpenTrainInv', trainDbTable.trainid)
                end,
                ['stopEngine'] = function()
                    VORPcore.NotifyRightTip(_U("engineStopped"), 4000)
                    EngineStarted = false
                    MenuData.CloseAll()
                    drivingTrainMenu(trainConfigTable, trainDbTable)
                    Citizen.InvokeNative(0x9F29999DFDF2AEB8, CreatedTrain, 0.0)
                end,
                ['startEngine'] = function()
                    VORPcore.NotifyRightTip(_U("engineStarted"), 4000)
                    EngineStarted = true
                    MenuData.CloseAll()
                    drivingTrainMenu(trainConfigTable, trainDbTable)
                    maxSpeedCalc(speed)
                end,
                ['deleteTrain'] = function()
                    TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false, CreatedTrain)
                    RemoveBlip(TrainBlip)
                    MenuData.CloseAll()
                    DeleteEntity(CreatedTrain)
                    hideHUD()
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