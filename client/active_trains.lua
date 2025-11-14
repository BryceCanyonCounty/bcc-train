---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

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
