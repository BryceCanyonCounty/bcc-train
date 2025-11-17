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
            -- Prefer labels provided in the destination config; fall back to raw id
            local labelMap = {}
            if destination.items and type(destination.items) == 'table' then
                for _, it in ipairs(destination.items) do
                    if it and it.item and it.label then labelMap[it.item] = it.label end
                end
            end
            for _, missing in ipairs(itemCheck.missingItems) do
                local label = (missing and missing.item) and (labelMap[missing.item] or tostring(missing.item)) or tostring(missing.item)
                missingText = missingText .. string.format("\n%s: %d/%d", label, missing.have, missing.needed)
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
