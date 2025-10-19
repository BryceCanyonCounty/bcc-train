-- Train Delivery Mission
local Core = exports.vorp_core:GetCore()
local MiniGame = exports['bcc-minigames'].initiate()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

local DeliveryPrompt = 0
local DeliveryGroup = GetRandomIntInRange(0, 0xffffff)
local DeliveryPromptStarted = false

local function StartDeliveryPrompt()
    if DeliveryPromptStarted then
        DBG.Success('Delivery Prompt already started')
        return
    end

    if not DeliveryGroup then
        DBG.Error('DeliveryGroup not initialized')
        return
    end

    if not Config or not Config.keys or not Config.keys.delivery then
        DBG.Error('Delivery Prompt key is not configured properly')
        return
    end

    DeliveryPrompt = UiPromptRegisterBegin()
    if not DeliveryPrompt or DeliveryPrompt == 0 then
        DBG.Error('Failed to register DeliveryPrompt')
        return
    end
    UiPromptSetControlAction(DeliveryPrompt, Config.keys.delivery)
    UiPromptSetText(DeliveryPrompt, CreateVarString(10, 'LITERAL_STRING', _U('start')))
    UiPromptSetEnabled(DeliveryPrompt, true)
    UiPromptSetVisible(DeliveryPrompt, true)
    Citizen.InvokeNative(0x74C7D7B72ED0D3CF, DeliveryPrompt, 'MEDIUM_TIMED_EVENT') -- PromptSetStandardizedHoldMode
    UiPromptSetGroup(DeliveryPrompt, DeliveryGroup, 0)
    UiPromptRegisterEnd(DeliveryPrompt)

    DeliveryPromptStarted = true
    DBG.Success('Delivery Prompt started successfully')
end

function DeliveryMission(station, presetDestination)
    -- Validate station parameter
    if not station or not Stations[station] then
        DBG.Error('Invalid station provided to DeliveryMission')
        return
    end

    local destination = {}
    local locations = {}
    local messageSent = false

    -- Validate delivery locations config
    if not DeliveryLocations then
        DBG.Error('Delivery locations configuration not found')
        return
    end

    for locationKey, locationCfg in pairs(DeliveryLocations) do
        if locationCfg.enabled ~= false and locationCfg.outWest == Stations[station].train.outWest then
            table.insert(locations, locationCfg)
        end
    end

    if #locations == 0 then
        DBG.Error(string.format('No delivery locations found for station: %s', station))
        Core.NotifyRightTip(_U('noDeliveryLocations'), 4000)
        return
    end

    -- Use the provided destination (from confirmation menu) if available to keep client/server in sync
    if presetDestination and type(presetDestination) == 'table' then
        destination = presetDestination

        -- If server returned a sanitized destination without vector3 userdata, enrich coords from config by name
        if (not destination.trainCoords or not destination.deliveryCoords) and DeliveryLocations then
            for _, loc in pairs(DeliveryLocations) do
                if loc.name == destination.name then
                    destination.trainCoords = destination.trainCoords or loc.trainCoords
                    destination.deliveryCoords = destination.deliveryCoords or loc.deliveryCoords
                    destination.radius = destination.radius or loc.radius
                    destination.outWest = destination.outWest or loc.outWest
                    break
                end
            end
        end
    else
        destination = locations[math.random(1, #locations)]
    end

    -- Ensure coords are vector3 objects (server may have sent plain tables)
    if destination.trainCoords and type(destination.trainCoords) == 'table' and destination.trainCoords.x then
        destination.trainCoords = vector3(destination.trainCoords.x, destination.trainCoords.y, destination.trainCoords.z)
    end
    if destination.deliveryCoords and type(destination.deliveryCoords) == 'table' and destination.deliveryCoords.x then
        destination.deliveryCoords = vector3(destination.deliveryCoords.x, destination.deliveryCoords.y, destination.deliveryCoords.z)
    end

    -- Check if player has required items for this destination
    if destination.requireItem and destination.items then
        local itemCheck = Core.Callback.TriggerAwait('bcc-train:CheckDeliveryItems', destination)
        if not itemCheck.hasItems then
            local missingText = _U('missingDeliveryItems')
            for _, missing in ipairs(itemCheck.missingItems) do
                missingText = missingText .. string.format("\n%s: %d/%d", missing.item, missing.have, missing.needed)
            end
            Core.NotifyRightTip(missingText, 6000)
            return
        end
    end

    DestinationBlip = Citizen.InvokeNative(0x45F13B7E0A15C880, -1282792512, destination.trainCoords, 10.0) -- BlipAddForRadius
    Citizen.InvokeNative(0x9CB1A1623062F402, DestinationBlip, _U('deliverySpot')) -- SetBlipName

    Core.NotifyRightTip(_U('goToDeliverSpot'), 4000)
    local beenIn = false
    while InMission do
        local sleep = 1000
        local distance = #(GetEntityCoords(MyTrain) - destination.trainCoords)
        if distance <= destination.radius then
            sleep = 0
            if not messageSent then
                Core.NotifyRightTip(_U('goDeliver'), 4000)
                messageSent = true
            end
            beenIn = true
            if Citizen.InvokeNative(0x78C3311A73135241, MyTrain) then -- IsVehicleStopped
                RemoveBlip(DestinationBlip)
                TriggerEvent('bcc-train:PlayerDelivery', destination)
                break
            end
        end
        if beenIn and distance > destination.radius then
            beenIn = false
            messageSent = false
            Core.NotifyRightTip(_U('trainTooFar'), 4000)
        end
        Wait(sleep)
    end
end

AddEventHandler('bcc-train:PlayerDelivery', function(destination)
    StartDeliveryPrompt()
    local deliveryCoords = destination.deliveryCoords
    DeliveryBlip = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, deliveryCoords) -- BlipAddForCoords
    Citizen.InvokeNative(0x9CB1A1623062F402, DeliveryBlip, _U('deliverySpot')) -- SetBlipName

    while InMission do
        local sleep = 1000
        local distance = #(GetEntityCoords(PlayerPedId()) - deliveryCoords)
        if distance <= 2 then
            sleep = 0
            UiPromptSetActiveGroupThisFrame(DeliveryGroup, CreateVarString(10, 'LITERAL_STRING', _U('completeDelivery')), 1, 0, 0, 0)
            if Citizen.InvokeNative(0xE0F65F0640EF0617, DeliveryPrompt) then -- PromptHasHoldModeCompleted
                Wait(500)
                MiniGame.Start('skillcheck', Config.minigame, function(result)
                    if result.passed then
                        local cash = (destination.rewards and destination.rewards.cash) or 0
                        Core.NotifyRightTip(_U('deliveryDone') .. cash, 4000)
                        TriggerServerEvent('bcc-train:DeliveryPay', destination)
                        TriggerServerEvent('bcc-train:SetPlayerCooldown', 'delivery')
                    else
                        Core.NotifyRightTip(_U('missionFailed'), 4000)
                    end
                    RemoveBlip(DeliveryBlip)
                    InMission = false
                end)
                break
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('bcc-train:DeliveryHelper', function()
    while InMission do
        Wait(1000)
        if IsEntityDead(PlayerPedId()) or not MyTrain or MyTrain == 0 then
            TriggerEvent('bcc-train:ResetTrain')
            break
        end
    end
end)
