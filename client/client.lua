local Core = exports.vorp_core:GetCore()
local Menu = exports.vorp_menu:GetMenuData()
local MiniGame = exports['bcc-minigames'].initiate()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

local IsShopClosed = false
local DrivingMenuOpened = false
-- Prompts
local MenuPrompt = 0
local MenuGroup = GetRandomIntInRange(0, 0xffffff)
local BridgePrompt = 0
local BridgeGroup = GetRandomIntInRange(0, 0xffffff)
local MainPromptsStarted = false

local function StartMainPrompts()
    if MainPromptsStarted then
        DBG.Success('Main Prompts already started')
        return
    end

    if not MenuGroup then
        DBG.Error('MenuGroup not initialized')
        return
    end

    if not Config or not Config.keys or not Config.keys.station or not Config.keys.bridge then
        DBG.Error('Prompt keys are not configured properly')
        return
    end

    MenuPrompt = UiPromptRegisterBegin()
    if not MenuPrompt or MenuPrompt == 0 then
        DBG.Error('Failed to register MenuPrompt')
        return
    end
    UiPromptSetControlAction(MenuPrompt, Config.keys.station)
    UiPromptSetText(MenuPrompt, CreateVarString(10, 'LITERAL_STRING', _U('openMainMenu')))
    UiPromptSetVisible(MenuPrompt, true)
    UiPromptSetStandardMode(MenuPrompt, true)
    UiPromptSetGroup(MenuPrompt, MenuGroup, 0)
    UiPromptRegisterEnd(MenuPrompt)

    BridgePrompt = UiPromptRegisterBegin()
    if not BridgePrompt or BridgePrompt == 0 then
        DBG.Error('Failed to register BridgePrompt')
        return
    end
    UiPromptSetControlAction(BridgePrompt, Config.keys.bridge)
    UiPromptSetText(BridgePrompt, CreateVarString(10, 'LITERAL_STRING', _U('blowUpBridge')))
    UiPromptSetEnabled(BridgePrompt, true)
    UiPromptSetVisible(BridgePrompt, true)
    Citizen.InvokeNative(0x74C7D7B72ED0D3CF, BridgePrompt, 'MEDIUM_TIMED_EVENT') -- PromptSetStandardizedHoldMode
    UiPromptSetGroup(BridgePrompt, BridgeGroup, 0)
    UiPromptRegisterEnd(BridgePrompt)

    MainPromptsStarted = true
    DBG.Success('Main Prompts started successfully')
end

-- Global blip system removed. Keeping server-side ActiveTrains for ownership/inventory logic.

-- Handle snapshot of active trains (for late joiners)
RegisterNetEvent('bcc-train:ActiveTrainsSnapshot', function(snapshot)
    if not snapshot or type(snapshot) ~= 'table' then return end
    ActiveTrainsLocal = ActiveTrainsLocal or {}
    -- Store snapshot entries locally; we will create blips only when the network entity is available
    for _, t in ipairs(snapshot) do
        -- Skip if this client is the owner (owner creates local blip elsewhere)
        if t.owner ~= GetPlayerServerId(PlayerId()) then
            ActiveTrainsLocal[t.netId] = {
                netId = t.netId,
                id = t.id,
                owner = t.owner,
                ownerName = t.ownerName,
                blipSprite = t.blipSprite,
                blipColor = t.blipColor,
                coords = t.coords
            }
        end
    end
end)

-- Request current active trains shortly after resource start so we show blips for existing trains
CreateThread(function()
    Wait(2000) -- give other resources time to initialize and potential entities to exist
    TriggerServerEvent('bcc-train:RequestActiveTrains')
end)

-- Client no longer reports player position to server (global blip system disabled)

-- Local maps for entity-attached blips
ActiveTrainBlips = ActiveTrainBlips or {} -- netId -> blip handle
ActiveTrainsLocal = ActiveTrainsLocal or {} -- netId -> train meta

-- Worker: try to resolve network entities and attach blips when possible
CreateThread(function()
    while true do
        for netId, info in pairs(ActiveTrainsLocal) do
            local nid = tonumber(netId)
            if nid and nid > 0 then
                local ent = NetworkGetEntityFromNetworkId(nid)
                if ent and ent ~= 0 and DoesEntityExist(ent) then
                    -- If we don't already have a blip, create one attached to the entity
                    if not ActiveTrainBlips[netId] or not DoesBlipExist(ActiveTrainBlips[netId]) then
                        local blip = Citizen.InvokeNative(0x23f74c2fda6e7c61, -1749618580, ent) -- BlipAddForEntity
                        -- Set sprite: config might store a numeric sprite or a name
                        if info.blipSprite then
                            if type(info.blipSprite) == 'number' then
                                SetBlipSprite(blip, info.blipSprite, true)
                            else
                                SetBlipSprite(blip, joaat(info.blipSprite), true)
                            end
                        elseif Config.trainBlips and Config.trainBlips.sprite then
                            SetBlipSprite(blip, Config.trainBlips.sprite, true)
                        end

                        -- Set name (owner or standard)
                        local nameMode = (Config.trainBlips and Config.trainBlips.nameMode) or 'player'
                        local nameToUse = nil
                        if nameMode == 'player' and info.ownerName then
                            nameToUse = info.ownerName
                        elseif nameMode == 'standard' then
                            nameToUse = Config.trainBlips and Config.trainBlips.standardName or nil
                        end
                        if nameToUse then
                            Citizen.InvokeNative(0x9CB1A1623062F402, blip, nameToUse)
                        end

                        -- Color modifier
                        if info.blipColor and Config.BlipColors[info.blipColor] then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, blip, joaat(Config.BlipColors[info.blipColor]))
                        elseif Config.trainBlips and Config.trainBlips.color and Config.BlipColors[Config.trainBlips.color] then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, blip, joaat(Config.BlipColors[Config.trainBlips.color]))
                        end

                        ActiveTrainBlips[netId] = blip
                    end
                else
                    -- Entity not present: ensure we remove any blip we previously created
                    if ActiveTrainBlips[netId] and DoesBlipExist(ActiveTrainBlips[netId]) then
                        RemoveBlip(ActiveTrainBlips[netId])
                    end
                    ActiveTrainBlips[netId] = nil
                end
            else
                -- no numeric netId: clear any stale entry
                ActiveTrainBlips[netId] = nil
            end
        end
        Wait(1000)
    end
end)

-- Temporary train locator: creates coordinate blips for known trains for a short duration
TempTrainBlips = TempTrainBlips or {}
local TEMP_BLIP_DURATION = (Config.trainBlips and Config.trainBlips.showTrains and Config.trainBlips.showTrains.blipDuration) or 10

local function createTempCoordBlip(x, y, z, sprite, color, label)
    -- Returns a table { iconBlip = <blip>, radiusBlip = <blip> or nil }
    local iconBlip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, x, y, z) -- BlipAddForCoords
    if sprite then
        if type(sprite) == 'number' then
            SetBlipSprite(iconBlip, sprite, true)
        else
            SetBlipSprite(iconBlip, joaat(sprite), true)
        end
    elseif Config.trainBlips and Config.trainBlips.sprite then
        SetBlipSprite(iconBlip, Config.trainBlips.sprite, true)
    end
    if color then
        DBG.Info('createTempCoordBlip: requested icon color key = ' .. tostring(color))
    end
    if color and Config.BlipColors[color] then
        DBG.Info('createTempCoordBlip: applying icon modifier = ' .. tostring(Config.BlipColors[color]))
        Citizen.InvokeNative(0x662D364ABF16DE2F, iconBlip, joaat(Config.BlipColors[color]))
    elseif Config.trainBlips and Config.trainBlips.color and Config.BlipColors[Config.trainBlips.color] then
        DBG.Info('createTempCoordBlip: applying default trainBlips color = ' .. tostring(Config.BlipColors[Config.trainBlips.color]))
        Citizen.InvokeNative(0x662D364ABF16DE2F, iconBlip, joaat(Config.BlipColors[Config.trainBlips.color]))
    end
    if label then
        Citizen.InvokeNative(0x9CB1A1623062F402, iconBlip, label)
    end
    -- Optionally create a radius blip for better visibility
    local radiusBlip = nil
    local radius = Config.trainBlips and Config.trainBlips.showTrains and Config.trainBlips.showTrains.tempRadius or 0
    local radiusHash = Config.trainBlips and Config.trainBlips.showTrains and Config.trainBlips.showTrains.tempRadiusHash
    if radius and radius > 0 and radiusHash then
        local vec = vector3(x, y, z)
        radiusBlip = Citizen.InvokeNative(0x45F13B7E0A15C880, radiusHash, vec, radius) -- BlipAddForRadius
        -- Apply color modifier to radius blip if available
        if color and Config.BlipColors[color] then
            DBG.Info('createTempCoordBlip: applying radius modifier from color key = ' .. tostring(color))
            Citizen.InvokeNative(0x662D364ABF16DE2F, radiusBlip, joaat(Config.BlipColors[color]))
        elseif Config.trainBlips and Config.trainBlips.showTrains and Config.trainBlips.showTrains.tempColor and Config.BlipColors[Config.trainBlips.showTrains.tempColor] then
            DBG.Info('createTempCoordBlip: applying radius modifier from tempColor = ' .. tostring(Config.trainBlips.showTrains.tempColor))
            Citizen.InvokeNative(0x662D364ABF16DE2F, radiusBlip, joaat(Config.BlipColors[Config.trainBlips.showTrains.tempColor]))
        else
            DBG.Info('createTempCoordBlip: no radius color modifier available for color key = ' .. tostring(color))
        end
    end

    return { iconBlip = iconBlip, radiusBlip = radiusBlip }
end

local function showTrainsCommandImpl()
    ActiveTrainsLocal = ActiveTrainsLocal or {}
    TempTrainBlips = TempTrainBlips or {}

    local found = false
    for netId, info in pairs(ActiveTrainsLocal) do
        if info and info.owner ~= GetPlayerServerId(PlayerId()) then
            found = true
            -- If an entity-attached blip exists we skip showing temp coord blip
            if ActiveTrainBlips and ActiveTrainBlips[netId] and DoesBlipExist(ActiveTrainBlips[netId]) then
                -- already visible
            else
                local x,y,z = nil,nil,nil
                if info.coords and info.coords.x then
                    x = info.coords.x; y = info.coords.y; z = info.coords.z
                else
                    local nid = tonumber(netId)
                    if nid and nid > 0 then
                        local ent = NetworkGetEntityFromNetworkId(nid)
                        if ent and ent ~= 0 and DoesEntityExist(ent) then
                            local c = GetEntityCoords(ent)
                            x, y, z = c.x, c.y, c.z
                        end
                    end
                end

                if x and y and z then
                    if not TempTrainBlips[netId] or not DoesBlipExist(TempTrainBlips[netId]) then
                        local label = nil
                        local nameMode = (Config.trainBlips and Config.trainBlips.nameMode) or 'player'
                        if nameMode == 'player' and info.ownerName then label = info.ownerName end
                        if nameMode == 'standard' and Config.trainBlips and Config.trainBlips.standardName then label = Config.trainBlips.standardName end

                        local displayColor = nil
                        if Config.trainBlips and Config.trainBlips.showTrains and Config.trainBlips.showTrains.tempColor then
                            displayColor = Config.trainBlips.showTrains.tempColor
                        else
                            displayColor = info.blipColor
                        end
                        local blipHandles = createTempCoordBlip(x, y, z, info.blipSprite, displayColor, label)
                        TempTrainBlips[netId] = blipHandles

                        CreateThread(function()
                            Wait((TEMP_BLIP_DURATION or 10) * 1000)
                            local handles = TempTrainBlips[netId]
                            if handles then
                                if handles.iconBlip and DoesBlipExist(handles.iconBlip) then
                                    RemoveBlip(handles.iconBlip)
                                end
                                if handles.radiusBlip and DoesBlipExist(handles.radiusBlip) then
                                    RemoveBlip(handles.radiusBlip)
                                end
                            end
                            TempTrainBlips[netId] = nil
                        end)
                    end
                end
            end
        end
    end

    if not found then
        Core.NotifyRightTip(_U('noActiveTrains'), 4000)
    end
end

RegisterCommand('showtrains', function()
    local allowed = Core.Callback.TriggerAwait('bcc-train:CanUseShowTrains')
    if not allowed then return end

    -- If we have no snapshot yet, request one and wait briefly for it to arrive
    ActiveTrainsLocal = ActiveTrainsLocal or {}
    local hasAny = false
    for _ in pairs(ActiveTrainsLocal) do hasAny = true; break end
    if not hasAny then
        TriggerServerEvent('bcc-train:RequestActiveTrains')
        local waited = 0
        while waited < 1500 do
            -- check if snapshot populated
            for _ in pairs(ActiveTrainsLocal) do hasAny = true; break end
            if hasAny then break end
            Wait(100)
            waited = waited + 100
        end
    end
    showTrainsCommandImpl()
end, false)

local function isShopClosed(stationCfg)
    local hour = GetClockHours()
    local hoursActive = stationCfg.shop.hours.active

    if not hoursActive then
        return false
    end

    local openHour = stationCfg.shop.hours.open
    local closeHour = stationCfg.shop.hours.close

    if openHour < closeHour then
        -- Normal: shop opens and closes on the same day
        return hour < openHour or hour >= closeHour
    else
        -- Overnight: shop closes on the next day
        return hour < openHour and hour >= closeHour
    end
end

local function ManageBlip(station, closed)
    local stationCfg = Stations[station]

    if (closed and not stationCfg.blip.show.closed) or (not stationCfg.blip.show.open) then
        if stationCfg.Blip then
            RemoveBlip(stationCfg.Blip)
            stationCfg.Blip = nil
        end
        return
    end

    if not stationCfg.Blip then
        stationCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, stationCfg.npc.coords) -- BlipAddForCoords
        SetBlipSprite(stationCfg.Blip, stationCfg.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, stationCfg.Blip, stationCfg.blip.name)               -- SetBlipName
    end

    local color = stationCfg.blip.color.open
    if stationCfg.shop.jobsEnabled then color = stationCfg.blip.color.job end
    if closed then color = stationCfg.blip.color.closed end

    if Config.BlipColors[color] then
        Citizen.InvokeNative(0x662D364ABF16DE2F, stationCfg.Blip, joaat(Config.BlipColors[color])) -- BlipAddModifier
    else
        print('Error: Blip color not defined for color: ' .. tostring(color))
    end
end

local function LoadModel(model, modelName)
    if not IsModelValid(model) then
        return print('Invalid model:', modelName)
    end

    if not HasModelLoaded(model) then
        RequestModel(model, false)

        local timeout = 10000
        local startTime = GetGameTimer()

        while not HasModelLoaded(model) do
            if GetGameTimer() - startTime > timeout then
                print('Failed to load model:', modelName)
                return
            end
            Wait(10)
        end
    end
end

local function AddNPC(station)
    local stationCfg = Stations[station]
    local coords = stationCfg.npc.coords

    if not stationCfg.NPC then
        local modelName = stationCfg.npc.model
        local model = joaat(modelName)
        LoadModel(model, modelName)

        stationCfg.NPC = CreatePed(model, coords.x, coords.y, coords.z - 1, stationCfg.npc.heading, false, false, false,
            false)
        Citizen.InvokeNative(0x283978A15512B2FE, stationCfg.NPC, true) -- SetRandomOutfitVariation

        SetEntityCanBeDamaged(stationCfg.NPC, false)
        SetEntityInvincible(stationCfg.NPC, true)
        Wait(500)
        FreezeEntityPosition(stationCfg.NPC, true)
        SetBlockingOfNonTemporaryEvents(stationCfg.NPC, true)
    end
end

local function RemoveNPC(station)
    local stationCfg = Stations[station]

    if stationCfg.NPC then
        DeleteEntity(stationCfg.NPC)
        stationCfg.NPC = nil
    end
end

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

-- Key monitoring for train inventory
CreateThread(function()
    local invKey = Config.keys.inventory

    while true do
        Wait(0)

        if IsControlJustPressed(0, invKey) then
            ExecuteCommand('trainInv')
            Wait(500)
        end
    end
end)

RegisterCommand('trainInv', function()
    local isInTrain = IsPedInAnyTrain(PlayerPedId())
    DBG.Info('Open train inventory command triggered. Is in train: ' .. tostring(isInTrain))
    TriggerServerEvent('bcc-train:OpenInventory', isInTrain)
end, false)

AddEventHandler('playerDropped', function()
    if MyTrain ~= 0 then
        if DoesEntityExist(MyTrain) then
            DeleteEntity(MyTrain)
        end
        MyTrain = 0
    TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false, nil, TrainId, SpawnedStation, nil)
        -- Ensure driving UI state cleared when player drops
        TriggerEvent('bcc-train:DrivingMenuClosed')
    end
end)

RegisterNetEvent('bcc-train:StartLockpick', function(trainId)
    -- Validate trainId parameter
    if not trainId or type(trainId) ~= 'number' then
        DBG.Error(string.format('Invalid trainId provided for lockpick: %s', tostring(trainId)))
        return
    end

    -- Validate config exists
    if not Config.lockPick then
        DBG.Error('Lockpick configuration not found')
        return
    end

    -- Determine degrees based on config
    local degrees = {}
    if Config.lockPick.randomDegrees then

        -- Use random degrees
        degrees = {
            math.random(0, 360),
            math.random(0, 360),
            math.random(0, 360)
        }
    else
        -- Use static degrees from config
        degrees = Config.lockPick.staticDegrees or { 90, 180, 270 } -- Fallback if not configured
    end

    -- Minigame Config
    local cfg = {
        focus = true,                                   -- Should minigame take nui focus
        cursor = true,                                  -- Should minigame have cursor  (required for lockpick)
        maxattempts = Config.lockPick.maxAttempts or 3, -- How many fail attempts are allowed before game over
        threshold = Config.lockPick.difficulty or 20,   -- +- threshold to the stage degree (bigger number means easier)
        hintdelay = Config.lockPick.hintdelay or 100,   -- milliseconds delay on when the circle will shake to show lockpick is in the right position.
        stages = {
            {
                deg = degrees[1] -- 0-360 degrees
            },
            {
                deg = degrees[2] -- 0-360 degrees
            },
            {
                deg = degrees[3] -- 0-360 degrees
            }
        }
    }

    MiniGame.Start('lockpick', cfg, function(result)
        if not result then
            DBG.Error('Lockpick minigame returned nil result')
            Core.NotifyRightTip(_U('pickAttemptFailed'), 4000)
            TriggerServerEvent('bcc-train:ConsumeLockpick')
            return
        end

        local success = (type(result) == 'table' and result.unlocked) or (result == true)
        if success then
            TriggerServerEvent('bcc-train:OpenInventoryAfterLockpick', trainId)
        else
            Core.NotifyRightTip(_U('pickAttemptFailed'), 4000)
            TriggerServerEvent('bcc-train:ConsumeLockpick')
        end
    end)
end)

-- Blow-up Bacchus Bridge
RegisterNetEvent('bcc-train:BridgeFall', function()
    local ran = 0
    local playerCoords = GetEntityCoords(PlayerPedId())

    repeat
        local object = GetRayfireMapObject(playerCoords.x, playerCoords.y, playerCoords.z, 10000.0, 'des_trn3_bridge')
        if object ~= 0 then
            SetStateOfRayfireMapObject(object, 4)
        end

        Wait(100)
        AddExplosion(521.13, 1754.46, 187.65, 28, 1.0, true, false, 0)
        AddExplosion(507.28, 1762.3, 187.77, 28, 1.0, true, false, 0)
        AddExplosion(527.21, 1748.86, 187.8, 28, 1.0, true, false, 0)
        Wait(100)

        if object ~= 0 then
            SetStateOfRayfireMapObject(object, 6) -- SetStateOfRayfireMapObject
        end

        ran = ran + 1
    until ran == 2 --has to run twice no idea why

    --Spawning ghost train model as the game engine wont allow trains to hit each other this will slow the trains down automatically if near the exploded part of the bridge
    Wait(1000)
    local trainHash = joaat('engine_config')
    LoadTrainCars(trainHash, false)                                                                                            -- false = not a preview (ghost train for bridge)
    local ghostTrain = Citizen.InvokeNative(0xc239dbd9a57d2a71, trainHash, 499.69, 1768.78, 188.77, false, false, true,
        false)                                                                                                                 -- CreateMissionTrain

    -- Freeze Train on Spawn
    Citizen.InvokeNative(0xDFBA6BBFF7CCAFBB, ghostTrain, 0.0) -- SetTrainSpeed
    Citizen.InvokeNative(0x01021EB2E96B793C, ghostTrain, 0.0) -- SetTrainCruiseSpeed

    SetEntityVisible(ghostTrain, false)
    SetEntityCollision(ghostTrain, false, false)
end)

CreateThread(function()
    if Config.bacchusBridge.enabled then
        local bridgeCoords = Config.bacchusBridge.coords
        while true do
            local sleep = 1000
            local distance = #(GetEntityCoords(PlayerPedId()) - bridgeCoords)
            if distance <= 2 then
                sleep = 0
                UiPromptSetActiveGroupThisFrame(BridgeGroup, CreateVarString(10, 'LITERAL_STRING', _U('bacchusBridge')),
                    1, 0, 0, 0)
                if Citizen.InvokeNative(0xE0F65F0640EF0617, BridgePrompt) then -- PromptHasHoldModeCompleted
                    Wait(500)
                    TriggerServerEvent('bcc-train:BridgeFallHandler', false)
                end
            end
            Wait(sleep)
        end
    end
end)

RegisterCommand('trainEnter', function()
    if MyTrain == 0 then
        Core.NotifyRightTip(_U('noBoat'), 4000)
        return
    end

    if not Citizen.InvokeNative(0xE052C1B1CAA4ECE4, MyTrain, -1) then return end -- IsVehicleSeatFree

    local playerPed = PlayerPedId()
    local callDist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyTrain))
    if callDist < 50 then
        DoScreenFadeOut(500)
        Wait(500)
        SetPedIntoVehicle(playerPed, MyTrain, -1)
        Wait(500)
        DoScreenFadeIn(500)
    else
        Core.NotifyRightTip(_U('tooFar'), 4000)
    end
end, false)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end

    if MyTrain ~= 0 then
        if DoesEntityExist(MyTrain) then
            DeleteEntity(MyTrain)
        end
        MyTrain = 0
        -- Notify server about train cleanup
    TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false, nil, TrainId, SpawnedStation, nil)
        -- Ensure driving UI state cleared during resource stop
        TriggerEvent('bcc-train:DrivingMenuClosed')
    end

    -- Clean up preview train
    if PreviewTrain and DoesEntityExist(PreviewTrain) then
        DeleteEntity(PreviewTrain)
        PreviewTrain = nil
    end

    for _, stationCfg in pairs(Stations) do
        if stationCfg.Blip then
            RemoveBlip(stationCfg.Blip)
            stationCfg.Blip = nil
        end
        if stationCfg.NPC then
            DeleteEntity(stationCfg.NPC)
            stationCfg.NPC = nil
        end
    end

    Menu.CloseAll()
    DestroyAllCams(true)
    DisplayRadar(true)
    TrainShopMenu:Close()

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
end)
