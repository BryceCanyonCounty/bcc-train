-- Delivery missions: mission management, rewards, and cooldowns

local ActiveMissions = {} -- Track active delivery missions
local PreviewMissions = {} -- Temporary precomputed previews for clients
local PREVIEW_EXPIRY = (Config and Config.previewExpirySeconds) or 300 -- seconds (default 5 minutes)

local function isPreviewValid(src)
    local p = PreviewMissions[src]
    if not p or not p.timestamp then return false end
    if os.time() - p.timestamp > PREVIEW_EXPIRY then
        PreviewMissions[src] = nil
        return false
    end
    return true
end
local CooldownData = {}

-- Mission tracking functions
local function startDeliveryMission(source, destinationKey)
    if not source or not destinationKey then
        return false
    end

    -- Look up actual destination config from server-side DeliveryLocations
    if type(destinationKey) ~= 'string' or not DeliveryLocations[destinationKey] then
        DBG.Error(string.format('Invalid or missing destination key: %s', tostring(destinationKey)))
        return false
    end

    local destination = DeliveryLocations[destinationKey]
    DBG.Info(string.format('Looking up destination from server config: %s', tostring(destinationKey)))

    local user = Core.getUser(source)
    if not user then
        return false
    end

    local character = user.getUsedCharacter
    if not character then
        return false
    end

    -- Check if destination requires items (from server config only)
    if destination.requireItem and destination.items and type(destination.items) == 'table' then
        DBG.Info(string.format('Mission requires items: %d items configured', #destination.items))
        for _, requiredItem in ipairs(destination.items) do
            local itemCount = exports.vorp_inventory:getItemCount(source, nil, requiredItem.item)
            if itemCount < requiredItem.quantity then
                local itemLabel = requiredItem.label or tostring(requiredItem.item)
                Core.NotifyRightTip(source, _U('missingDeliveryItems') .. ' ' .. tostring(requiredItem.quantity) .. ' x ' .. tostring(itemLabel), 4000)
                return false
            end
        end

        -- Remove required items from inventory
        for _, requiredItem in ipairs(destination.items) do
            DBG.Info(string.format('Removing item for mission start: src=%s item=%s qty=%s', tostring(source), tostring(requiredItem.item), tostring(requiredItem.quantity)))
            exports.vorp_inventory:subItem(source, requiredItem.item, requiredItem.quantity)
            DBG.Info(string.format('Requested removal: src=%s item=%s qty=%s', tostring(source), tostring(requiredItem.item), tostring(requiredItem.quantity)))
        end

        Core.NotifyRightTip(source, _U('deliveryItemsConsumed'), 3000)
    end

    -- Create mission entry with timestamp and destination key
    ActiveMissions[source] = {
        type = 'delivery',
        charIdentifier = character.charIdentifier,
        destinationKey = destinationKey,
        startTime = os.time(),
        completed = false
    }

    DBG.Info(string.format('Started delivery mission for player %s to %s (key: %s)', tostring(source), tostring(destination.name or 'unknown'), tostring(destinationKey)))
    return true
end

local function validateAndCompleteDeliveryMission(source)
    if not source then
        DBG.Error('Invalid source for delivery validation')
        return false
    end

    -- Get current character for validation
    local user = Core.getUser(source)
    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(source)))
        return false
    end

    local character = user.getUsedCharacter
    if not character then
        DBG.Error('Character not found for user')
        return false
    end

    local mission = ActiveMissions[source]
    if not mission then
        DBG.Warning(string.format('No active mission found for player %s', tostring(source)))
        return false
    end

    -- Verify the character attempting to complete is the same one that started the mission
    if mission.charIdentifier ~= character.charIdentifier then
        DBG.Warning(string.format('Character mismatch: mission started by %s but completion attempted by %s', tostring(mission.charIdentifier), tostring(character.charIdentifier)))
        Core.NotifyRightTip(source, _U('notYourMission'), 4000)
        return false
    end

    if mission.type ~= 'delivery' then
        DBG.Warning(string.format('Player %s attempted to complete wrong mission type', tostring(source)))
        return false
    end

    if mission.completed then
        DBG.Warning(string.format('Player %s attempted to complete already completed mission', tostring(source)))
        return false
    end

    -- Basic validation - ensure destination matches and mission isn't too old (prevent replay attacks)
    local maxMissionTime = 3600 -- 1 hour maximum mission time
    if os.time() - mission.startTime > maxMissionTime then
        DBG.Warning(string.format('Mission expired for player %s', tostring(source)))
        Core.NotifyRightTip(source, _U('missionExpired'), 4000)
        ActiveMissions[source] = nil
        return false
    end

    -- Mark mission as completed
    mission.completed = true
    DBG.Info(string.format('Validated delivery mission completion for player %s (char: %s)', tostring(source), tostring(character.charIdentifier)))
    return true
end

RegisterNetEvent('bcc-train:DeliveryPay', function()
    local src = source
    local user = Core.getUser(src)

    -- Validate user exists
    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    local character = user.getUsedCharacter

    -- Validate mission completion first
    if not validateAndCompleteDeliveryMission(src) then
        Core.NotifyRightTip(src, _U('invalidMissionComplete'), 4000)
        return
    end

    -- Get mission data to look up destination from server config
    local mission = ActiveMissions[src]
    if not mission or not mission.destinationKey then
        DBG.Error('Mission data missing or invalid for delivery pay')
        return
    end

    -- Look up destination from server-side config using stored key
    local destination = DeliveryLocations[mission.destinationKey]
    if not destination or not destination.rewards or type(destination.rewards) ~= 'table' then
        DBG.Error(string.format('Invalid destination config for key: %s', tostring(mission.destinationKey)))
        return
    end

    local rewards = destination.rewards
    DBG.Info(string.format('Awarding rewards from server config for destination: %s', tostring(mission.destinationKey)))

    -- If the mission has previewRewards (precomputed when client accepted), use them
    local cashAmount = 0
    local goldAmount = 0
    local finalItemRewards = nil

    if mission.previewRewards and type(mission.previewRewards) == 'table' then
        cashAmount = mission.previewRewards.cash or 0
        goldAmount = mission.previewRewards.gold or 0
        finalItemRewards = mission.previewRewards.items or {}
    else
        -- Calculate random reward amounts (fallback to config-driven randomization)
        -- Validate and calculate cash reward (min/max format required)
        if rewards.cash then
            if type(rewards.cash) == 'table' and rewards.cash.min and rewards.cash.max then
                cashAmount = math.random(rewards.cash.min, rewards.cash.max)
            else
                DBG.Error('Invalid rewards.cash format - must be table with min/max properties')
            end
        end

        -- Validate and calculate gold reward (min/max format required)
        if rewards.gold then
            if type(rewards.gold) == 'table' and rewards.gold.min and rewards.gold.max then
                goldAmount = math.random(rewards.gold.min, rewards.gold.max)
            else
                DBG.Error('Invalid rewards.gold format - must be table with min/max properties')
            end
        end

        if rewards.items and type(rewards.items) ~= 'table' then
            DBG.Error('Invalid rewards.items type in server config')
            return
        end
    end

    -- Build reward notification messages
    local rewardMessages = {}
    local awardedItems = {}

    -- Award cash
    if cashAmount > 0 then
        character.addCurrency(0, cashAmount)
        table.insert(rewardMessages, string.format('$%s %s', tostring(cashAmount), _U('currencyCash')))
        DBG.Info(string.format('Awarded cash to src=%s amount=%s', tostring(src), tostring(cashAmount)))
    end

    -- Award gold
    if goldAmount > 0 then
        character.addCurrency(1, goldAmount)
        table.insert(rewardMessages, string.format('%s %s', tostring(goldAmount), _U('currencyGold')))
        DBG.Info(string.format('Awarded gold to src=%s amount=%s', tostring(src), tostring(goldAmount)))
    end

    -- Award item rewards via inventory export if present, but only if the player can carry them
    local failedAwards = {}
    local itemRewardSource = finalItemRewards or rewards.items
    if itemRewardSource and type(itemRewardSource) == 'table' then
        for _, it in ipairs(itemRewardSource) do
            if it and it.item then
                local qty = tonumber(it.quantity) or tonumber(it.qty) or tonumber(it.amount) or it.count
                if not qty and it.min and it.max then
                    qty = math.random(it.min, it.max)
                end
                qty = tonumber(qty) or 0

                if qty > 0 then
                    local canCarry = true
                    local failReason = 'Inventory full'

                    -- Check carry capacity if the export exists
                    if exports.vorp_inventory and exports.vorp_inventory.canCarryItem then
                        canCarry = exports.vorp_inventory:canCarryItem(src, it.item, qty)
                    end

                    if canCarry then
                        local success = exports.vorp_inventory:addItem(src, it.item, qty)
                        if success ~= false then
                            DBG.Info(string.format('Awarded item to src=%s item=%s qty=%s', tostring(src), tostring(it.item), tostring(qty)))
                            local label = it.label or tostring(it.item)
                            table.insert(awardedItems, string.format('%s x%d', label, qty))
                        else
                            table.insert(failedAwards, { item = it.item, label = it.label, quantity = qty, reason = 'Failed to add item' })
                            DBG.Warning(string.format('Failed to award item to src=%s item=%s qty=%s reason=addItem returned false', tostring(src), tostring(it.item), tostring(qty)))
                        end
                    else
                        table.insert(failedAwards, { item = it.item, label = it.label, quantity = qty, reason = failReason })
                        DBG.Warning(string.format('Failed to award item to src=%s item=%s qty=%s reason=%s', tostring(src), tostring(it.item), tostring(qty), tostring(failReason)))
                    end
                end
            end
        end
    end

    -- Notify player about successful rewards
    if #rewardMessages > 0 or #awardedItems > 0 then
        -- Send currency notification
        if #rewardMessages > 0 then
            local currencyMsg = _U('deliveryRewardsCurrency') .. ' ' .. table.concat(rewardMessages, ', ')
            DBG.Info(string.format('Sending currency notification to src=%s: %s', tostring(src), currencyMsg))
            Core.NotifyRightTip(src, currencyMsg, 5000)
        end

        -- Send item notification separately
        if #awardedItems > 0 then
            local itemMsg = _U('deliveryRewardsItems') .. ' ' .. table.concat(awardedItems, ', ')
            DBG.Info(string.format('Sending item notification to src=%s: %s', tostring(src), itemMsg))
            Core.NotifyRightTip(src, itemMsg, 5000)
        end
    else
        DBG.Info(string.format('No rewards to notify for src=%s (rewardMessages=%d, awardedItems=%d)', tostring(src), #rewardMessages, #awardedItems))
    end

    -- Notify player about failed awards (items that couldn't fit in inventory)
    if #failedAwards > 0 then
        local failedItemsList = {}
        for _, f in ipairs(failedAwards) do
            local label = f.label or tostring(f.item)
            table.insert(failedItemsList, string.format('%s x%d', label, f.quantity))
        end
        local msg = _U('couldNotAwardItemsHeader') .. ' ' .. table.concat(failedItemsList, ', ')
        DBG.Warning(string.format('Sending failed awards notification to src=%s: %s', tostring(src), msg))
        Core.NotifyRightTip(src, msg, 6000)
    end

    -- Clean up completed mission
    ActiveMissions[src] = nil

    Discord:sendMessage(
        _U('charNameWeb') ..
        character.firstname ..
        ' ' ..
        character.lastname ..
        _U('charIdentWeb') ..
        character.identifier ..
        _U('charIdWeb') ..
        character.charIdentifier ..
        _U('paidDeliveryWeb') ..
        tostring(rewards.cash or 0))
end)

RegisterNetEvent('bcc-train:StartDeliveryMission', function(destinationKey)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Validate destination key parameter
    if not destinationKey or type(destinationKey) ~= 'string' then
        DBG.Error('Invalid destination key provided for mission start')
        return
    end

    -- Check if player already has an active mission
    if ActiveMissions[src] then
        Core.NotifyRightTip(src, _U('alreadyInMission'), 4000)
        return
    end

    -- If a preview exists for this source, validate expiry and only allow start if destinationKey matches
    local preview = PreviewMissions[src]
    if preview then
        if not isPreviewValid(src) then
            Core.NotifyRightTip(src, _U('deliveryPreviewExpired'), 4000)
            return
        end
        if preview.destinationKey ~= destinationKey then
            DBG.Warning(string.format('StartDeliveryMission destination mismatch for src=%s (preview=%s requested=%s)', tostring(src), tostring(preview.destinationKey), tostring(destinationKey)))
            Core.NotifyRightTip(src, _U('deliveryStartFailed'), 4000)
            return
        end
    end

    if startDeliveryMission(src, destinationKey) then
        -- Attach preview rewards to mission if present
        if preview and preview.rewards then
            ActiveMissions[src].previewRewards = preview.rewards
            PreviewMissions[src] = nil
        end
        Core.NotifyRightTip(src, _U('deliveryStarted'), 4000)
    else
        Core.NotifyRightTip(src, _U('deliveryStartFailed'), 4000)
    end
end)

-- Server callback: compute a delivery preview (destination + exact rewards) for a station
Core.Callback.Register('bcc-train:RequestDeliveryPreview', function(source, cb, station)
    local src = source
    local user = Core.getUser(src)
    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(nil)
    end

    if not station or not Stations[station] then
        DBG.Error('Invalid station provided for delivery preview')
        return cb(nil)
    end

    -- Build eligible locations for station (match outWest)
    local candidates = {}
    for key, cfg in pairs(DeliveryLocations) do
        if cfg.enabled ~= false and cfg.outWest == Stations[station].train.outWest then
            table.insert(candidates, { key = key, cfg = cfg })
        end
    end

    if #candidates == 0 then
        return cb(nil)
    end

    local choice = candidates[math.random(1, #candidates)]
    local destinationKey = choice.key
    local destination = choice.cfg

    -- Compute rewards deterministically here
    local computed = { cash = 0, gold = 0, items = {} }
    if destination.rewards then
        local r = destination.rewards
        if r.cash and type(r.cash) == 'table' and r.cash.min and r.cash.max then
            computed.cash = math.random(r.cash.min, r.cash.max)
        end
        if r.gold and type(r.gold) == 'table' and r.gold.min and r.gold.max then
            computed.gold = math.random(r.gold.min, r.gold.max)
        end
        if r.items and type(r.items) == 'table' then
            for _, it in ipairs(r.items) do
                if it and it.item and type(it.min) == 'number' and type(it.max) == 'number' then
                    table.insert(computed.items, { item = it.item, label = it.label, quantity = math.random(it.min, it.max) })
                end
            end
        end
    end

    -- Store preview for this player (valid until they start the mission)
    PreviewMissions[src] = { destinationKey = destinationKey, rewards = computed, timestamp = os.time() }

    -- Return preview to client
    return cb({ destinationKey = destinationKey, destinationName = destination.name, rewards = computed })
end)

-- Provide a callback variant so clients can TriggerAwait and get immediate success/failure
Core.Callback.Register('bcc-train:StartDeliveryMission', function(source, cb, destinationKey)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb({ success = false, error = 'User not found' })
    end

    -- Validate destination key parameter
    if not destinationKey or type(destinationKey) ~= 'string' then
        DBG.Error('Invalid destination key provided for mission start (callback)')
        return cb({ success = false, error = 'Invalid destination key' })
    end

    -- Check if player already has an active mission
    if ActiveMissions[src] then
        return cb({ success = false, error = 'Already in mission' })
    end

    local ok = startDeliveryMission(src, destinationKey)
    if ok then
        -- If a preview exists for this source, attach it to the ActiveMissions entry
            local preview = PreviewMissions[src]
            if preview then
                if not isPreviewValid(src) then
                    return cb({ success = false, error = 'preview_expired' })
                end
                if preview.destinationKey == destinationKey and preview.rewards then
                    ActiveMissions[src].previewRewards = preview.rewards
                    PreviewMissions[src] = nil
                else
                    DBG.Warning(string.format('StartDeliveryMission (callback) preview mismatch for src=%s preview=%s requested=%s', tostring(src), tostring(preview and preview.destinationKey), tostring(destinationKey)))
                    -- continue without preview; do not fail the start solely for preview mismatch
                end
            end

        -- Look up and return full destination config from server (client needs it for display)
        local serverDestination = DeliveryLocations[destinationKey]
        if not serverDestination then
            DBG.Error(string.format('Failed to look up destination config for key: %s', tostring(destinationKey)))
            return cb({ success = false, error = 'Failed to retrieve destination config' })
        end
        return cb({ success = true, destination = serverDestination })
    else
        return cb({ success = false, error = 'Failed to start mission' })
    end
end)

RegisterNetEvent('bcc-train:SetPlayerCooldown', function(mission)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    -- Validate mission parameter
    if not mission or type(mission) ~= 'string' then
        DBG.Error('Invalid mission parameter provided for cooldown')
        return
    end

    local character = user.getUsedCharacter
    CooldownData[mission .. tostring(character.charIdentifier)] = os.time()
end)

Core.Callback.Register('bcc-train:CheckPlayerCooldown', function(source, cb, mission)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(false)
    end

    -- Validate mission parameter
    if not mission or type(mission) ~= 'string' then
        DBG.Error('Invalid mission parameter provided for cooldown check')
        return cb(false)
    end

    -- Validate config exists
    if not Config.cooldown or not Config.cooldown[mission] then
        DBG.Error(string.format('Cooldown configuration not found for mission: %s', mission))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local cooldown = Config.cooldown[mission]
    local missionId = mission .. tostring(character.charIdentifier)

    -- Check if player is on cooldown
    if CooldownData[missionId] then
        if os.difftime(os.time(), CooldownData[missionId]) >= cooldown * 60 then
            cb(false) -- Not on Cooldown
        else
            cb(true)  -- On Cooldown
        end
    else
        cb(false) -- Not on List, so not on cooldown
    end
end)
