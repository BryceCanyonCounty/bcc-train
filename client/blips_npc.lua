local Core = exports.vorp_core:GetCore()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

-- Temporary train locator: creates coordinate blips for known trains for a short duration
TempTrainBlips = TempTrainBlips or {}
local TEMP_BLIP_DURATION = (Config.trainBlips and Config.trainBlips.showTrains and Config.trainBlips.showTrains.blipDuration) or 10

function createTempCoordBlip(x, y, z, sprite, color, label)
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

function showTrainsCommandImpl()
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

function isShopClosed(stationCfg)
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

function ManageBlip(station, closed)
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

function LoadModel(model, modelName)
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

function AddNPC(station)
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

function RemoveNPC(station)
    local stationCfg = Stations[station]

    if stationCfg.NPC then
        DeleteEntity(stationCfg.NPC)
        stationCfg.NPC = nil
    end
end
