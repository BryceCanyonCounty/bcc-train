local Core = exports.vorp_core:GetCore()
local Menu = exports.vorp_menu:GetMenuData()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

-- Start Train
CreateThread(function()
    StartMainPrompts()
    SetRandomTrains(false)
    TriggerServerEvent('bcc-train:BridgeFallHandler', true)
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

        if InMenu or IsEntityDead(playerPed) then
            goto END
        end

        for station, stationCfg in pairs(Stations) do
            local distance = #(playerCoords - stationCfg.npc.coords)
            IsShopClosed = isShopClosed(stationCfg)

            ManageBlip(station, IsShopClosed)

            if distance > stationCfg.npc.distance or IsShopClosed then
                RemoveNPC(station)
            elseif stationCfg.npc.active then
                AddNPC(station)
            end

            if distance <= stationCfg.shop.distance then
                sleep = 0
                local promptText
                if IsShopClosed then
                    promptText = ('%s %s %d %s %d %s'):format(
                        stationCfg.shop.name,
                        _U('hours'),
                        stationCfg.shop.hours.open,
                        _U('to'),
                        stationCfg.shop.hours.close,
                        _U('hundred')
                    )
                else
                    promptText = stationCfg.shop.prompt
                end

                UiPromptSetActiveGroupThisFrame(MenuGroup, CreateVarString(10, 'LITERAL_STRING', promptText), 1, 0, 0, 0)
                UiPromptSetEnabled(MenuPrompt, not IsShopClosed)

                if not IsShopClosed then
                    if Citizen.InvokeNative(0xC92AC953F0A982AE, MenuPrompt) then -- PromptHasStandardModeCompleted
                        if stationCfg.shop.jobsEnabled then
                            local hasJob = Core.Callback.TriggerAwait('bcc-train:CheckJob', station)
                            if hasJob ~= true then
                                goto END
                            end
                        end
                        OpenShopMenu(station)
                    end
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

function OpenShopMenu(station)
    -- Validate station parameter
    if not station then
        DBG.Error('Invalid station provided to OpenShopMenu')
        return
    end

    -- Get station configuration
    local stationCfg = Stations[station]
    if not stationCfg or not stationCfg.train or not stationCfg.train.camera or not stationCfg.train.coords then
        DBG.Error('Invalid station configuration for camera setup in OpenShopMenu')
        return
    end

    -- Create and set up camera
    local trainCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(trainCam, stationCfg.train.camera.x, stationCfg.train.camera.y, stationCfg.train.camera.z)
    SetCamActive(trainCam, true)
    PointCamAtCoord(trainCam, stationCfg.train.coords.x, stationCfg.train.coords.y, stationCfg.train.coords.z)
    SetCamFov(trainCam, 50.0)

    -- Transition to camera and open menu
    DoScreenFadeOut(500)
    Wait(500)
    ShopMenu(station)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, false, false, 0)
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

AddEventHandler('bcc-train:TrainHandler', function(trainCfg, myTrainData)
    DrivingMenuOpened = false
    local despawnDist = Config.despawnDist or 300.0
    while MyTrain ~= 0 do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local isDead = IsEntityDead(playerPed)
        local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(MyTrain))
        if distance >= despawnDist or isDead then
            if MyTrain ~= 0 then
                if distance >= despawnDist and not isDead then
                    Core.NotifyRightTip(_U('trainReturnedDistance'), 4000)
                end
                TriggerEvent('bcc-train:ResetTrain')
                break
            end
        elseif distance <= 10 then
            sleep = 0
            if not Citizen.InvokeNative(0xE052C1B1CAA4ECE4, MyTrain, -1) and GetPedInVehicleSeat(MyTrain, -1) == playerPed then -- IsVehicleSeatFree
                if not DrivingMenuOpened then
                    DrivingMenuOpened = true
                    -- Freshly opening the driving menu (player just entered seat) should reset persisted speed
                    DrivingMenu(trainCfg, myTrainData, true)
                end
            else
                if DrivingMenuOpened then
                    -- Use centralized handler so persisted state (like DrivingMenuSpeed) is reset
                    TriggerEvent('bcc-train:DrivingMenuClosed')
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('bcc-train:TrainTag', function(trainCfg, myTrainData)
    local tagDist = trainCfg.gamerTag.distance
    local tagId = Citizen.InvokeNative(0xE961BF23EAB76B12, MyTrain, myTrainData.name) -- CreateMpGamerTagOnEntity
    while MyTrain ~= 0 do
        Wait(1000)
        local playerPed = PlayerPedId()
        local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyTrain))

        if dist <= tagDist and not Citizen.InvokeNative(0xEC5F66E459AF3BB2, playerPed, MyTrain) then -- IsPedOnSpecificVehicle
            Citizen.InvokeNative(0x93171DDDAB274EB8, tagId, 3)                                       -- SetMpGamerTagVisibility
        else
            if Citizen.InvokeNative(0x502E1591A504F843, tagId, MyTrain) then                         -- IsMpGamerTagActiveOnEntity
                Citizen.InvokeNative(0x93171DDDAB274EB8, tagId, 0)                                   -- SetMpGamerTagVisibility
            end
        end
    end
    Citizen.InvokeNative(0x839BFD7D7E49FE09, Citizen.PointerValueIntInitialized(tagId)) -- RemoveMpGamerTag
end)

-- Ensure DrivingMenu is closed when train is reset or player is ejected
AddEventHandler('bcc-train:DrivingMenuClosed', function()
    if DrivingMenuOpened then
        DrivingMenuOpened = false
        Menu.CloseAll()
        ForwardActive = false
        BackwardActive = false
    end
    -- reset persisted speed
    DrivingMenuSpeed = 0
end)

local function startPeriodicTrainStat(statName, getValueFn, setValueFn, cfgField, serverCallback, trainCfg, myTrainData)
    -- Runs in its own thread; waits the configured interval between server calls
    CreateThread(function()
        local interval = (trainCfg[cfgField].decreaseTime or 60) * 1000
        local emptyFlag = false
        while MyTrain ~= 0 do
            if EngineStarted and getValueFn() >= 1 then
                -- Wait the configured interval once (avoids extra small waits)
                Wait(interval)
                local ok, res = pcall(function()
                    return Core.Callback.TriggerAwait(serverCallback, TrainId, getValueFn(), trainCfg)
                end)
                if ok and res ~= nil then
                    setValueFn(tonumber(res))
                    if DrivingMenuOpened then
                        DrivingMenu(trainCfg, myTrainData, false)
                    end
                else
                    DBG.Error('Failed to update train ' .. statName)
                end
            else
                -- Ensure train won't move if engine isn't started or stat is depleted
                if MyTrain and MyTrain ~= 0 then
                    Citizen.InvokeNative(0x9F29999DFDF2AEB8, MyTrain, 0.0) -- SetTrainMaxSpeed
                end
                Wait(1000)
            end

            local current = getValueFn()
            if current <= 0 and not emptyFlag then
                emptyFlag = true
                EngineStarted = false
                if MyTrain and MyTrain ~= 0 then
                    Citizen.InvokeNative(0x9F29999DFDF2AEB8, MyTrain, 0.0) -- SetTrainMaxSpeed
                end
                if DrivingMenuOpened then
                    DrivingMenu(trainCfg, myTrainData, false)
                end
            elseif emptyFlag and current >= 1 then
                emptyFlag = false
            end
        end
    end)
end

AddEventHandler('bcc-train:FuelDecreaseHandler', function(trainCfg, myTrainData)
    -- get/set helpers for TrainFuel
    startPeriodicTrainStat('fuel', function() return TrainFuel end, function(v) TrainFuel = v end, 'fuel', 'bcc-train:DecTrainFuel', trainCfg, myTrainData)
end)

AddEventHandler('bcc-train:CondDecreaseHandler', function(trainCfg, myTrainData)
    -- get/set helpers for TrainCondition
    startPeriodicTrainStat('condition', function() return TrainCondition end, function(v) TrainCondition = v end, 'condition', 'bcc-train:DecTrainCond', trainCfg, myTrainData)
end)
