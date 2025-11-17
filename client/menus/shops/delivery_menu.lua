function DeliveryMissionConfirmation(station)
    -- Validate station parameter
    if not station or not Stations[station] then
        DBG.Error('Invalid station provided to DeliveryMissionConfirmation')
        return
    end

    local locations = {}

    -- Validate delivery locations config
    if not DeliveryLocations then
        DBG.Error('Delivery locations configuration not found')
        return
    end

    for locationKey, locationCfg in pairs(DeliveryLocations) do
        if locationCfg.enabled ~= false and locationCfg.outWest == Stations[station].train.outWest then
            table.insert(locations, {key = locationKey, config = locationCfg})
        end
    end

    if #locations == 0 then
        DBG.Error(string.format('No delivery locations found for station: %s', station))
        Core.NotifyRightTip(_U('noDeliveryLocations'), 4000)
        return
    end

    -- Select random destination
    local selectedLocation = locations[math.random(1, #locations)]
    local destinationKey = selectedLocation.key
    local destination = selectedLocation.config
    local stationCfg = Stations[station]

    -- Create confirmation page
    local ConfirmationPage = TrainShopMenu:RegisterPage('deliveryConfirmation:page')

    ConfirmationPage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    ConfirmationPage:RegisterElement('subheader', {
        value = _U('deliveryMission'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    ConfirmationPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    -- Show destination
    ConfirmationPage:RegisterElement('textdisplay', {
        value = _U('destination') .. (destination.name or _U('unknownLocation')),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    -- Show rewards (cash/gold/items)
    -- Rewards must be provided as a `rewards` table on the destination
    local rewards = destination.rewards or { cash = 0, gold = 0, items = {} }

    ConfirmationPage:RegisterElement('textdisplay', {
        value = _U('rewards'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    -- Cash
    ConfirmationPage:RegisterElement('textdisplay', {
        value = string.format('• %s: $%s', _U('currencyCash'), tostring(rewards.cash or 0)),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    -- Gold (only show if >0)
    if rewards.gold and rewards.gold > 0 then
        ConfirmationPage:RegisterElement('textdisplay', {
            value = string.format('• %s: %s', _U('currencyGold'), tostring(rewards.gold)),
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0',
                ['font-variant'] = 'small-caps',
                ['font-size'] = '0.83vw',
            }
        })
    end

    -- Items (each on its own line)
    if rewards.items and #rewards.items > 0 then
        -- Determine which ids still need resolution
        local idsToResolve = {}
        local needResolve = false
        for _, r in ipairs(rewards.items) do
            if r and r.item and not r.label then
                idsToResolve[#idsToResolve+1] = r.item
                needResolve = true
            end
        end

        local resolved = {}
        if needResolve then
            -- fall back to raw id if missing
            for _, id in ipairs(idsToResolve) do resolved[id] = tostring(id) end
        end

        for _, r in ipairs(rewards.items) do
            if r and r.item and r.quantity then
                local label = r.label or resolved[r.item] or tostring(r.item)
                ConfirmationPage:RegisterElement('textdisplay', {
                    value = string.format('• %sx %s', tostring(r.quantity), tostring(label)),
                    slot = 'content',
                    style = {
                        ['color'] = '#E0E0E0',
                        ['font-variant'] = 'small-caps',
                        ['font-size'] = '0.83vw',
                    }
                })
            end
        end
    end

    -- Show required items based on requireItem setting
    local itemCheck = nil
    if destination.requireItem then
        ConfirmationPage:RegisterElement('textdisplay', {
            value = _U('requiredItems'),
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0',
                ['font-variant'] = 'small-caps',
                ['font-size'] = '0.83vw',
            }
        })

        -- Check if destination has items configured
        if destination.items then
            -- Check if player has required items
            itemCheck = Core.Callback.TriggerAwait('bcc-train:CheckDeliveryItems', destination)

            -- Build a lookup map of required items with counts
            local requiredMap = {}
            if itemCheck and itemCheck.requiredItems then
                for _, r in ipairs(itemCheck.requiredItems) do
                    if r and r.item then requiredMap[r.item] = r end
                end
            end

            -- Prefer labels configured on each required item
            local reqLabels = {}
            for _, requiredItem in ipairs(destination.items) do
                -- Validate requiredItem structure
                if not requiredItem or not requiredItem.item or not requiredItem.quantity then
                    DBG.Warning('Invalid required item configuration found, skipping')
                    goto continue
                end

                -- Determine if the player has this required item and exact counts
                local reqInfo = requiredMap[requiredItem.item]
                local haveCount = reqInfo and tonumber(reqInfo.have) or 0
                local needCount = reqInfo and tonumber(reqInfo.needed) or requiredItem.quantity
                local hasItem = haveCount >= needCount
                local color = hasItem and '#E0E0E0' or '#FF6B6B'

                local reqLabel = requiredItem.label or reqLabels[requiredItem.item] or tostring(requiredItem.item)
                ConfirmationPage:RegisterElement('textdisplay', {
                    value = string.format('• %s: %d/%d', reqLabel, haveCount, needCount),
                    slot = 'content',
                    style = {
                        ['color'] = color,
                        ['font-variant'] = 'small-caps',
                        ['font-size'] = '0.83vw',
                    }
                })

                ::continue::
            end
        else
            ConfirmationPage:RegisterElement('textdisplay', {
                value = '• ' .. _U('noItemsConfigured'),
                slot = 'content',
                style = {
                    ['color'] = '#FF6B6B',
                    ['font-variant'] = 'small-caps',
                    ['font-size'] = '0.83vw',
                }
            })
        end
    else
        ConfirmationPage:RegisterElement('textdisplay', {
            value = _U('noRequiredItems'),
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0',
                ['font-variant'] = 'small-caps',
                ['font-size'] = '0.83vw',
            }
        })
    end

    ConfirmationPage:RegisterElement('bottomline', {
        slot = 'content',
        style = {}
    })

    ConfirmationPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    -- Check if player can start mission (reuse itemCheck result)
    local canStart = true
    if destination.requireItem and destination.items then
        canStart = itemCheck and itemCheck.hasItems or false
    end

    -- Start Mission (only shown when player can start)
    if canStart then
        ConfirmationPage:RegisterElement('button', {
            label = _U('startMission'),
            slot = 'footer',
            style = {
                ['color'] = '#E0E0E0',
            }
        }, function()
            -- Ask server to start the delivery mission (server will validate and remove items)
            -- Send only destination key - server will look up config
            local result = Core.Callback.TriggerAwait('bcc-train:StartDeliveryMission', destinationKey)
            if result and result.success then
                local serverDest = result.destination or destination
                InMission = true
                TrainShopMenu:Close()
                DeliveryMission(station, serverDest)
            else
                Core.NotifyRightTip(result and result.error or 'Failed to start mission', 4000)
            end
        end)
    else
        ConfirmationPage:RegisterElement('button', {
            label = _U('missingDeliveryItems'),
            slot = 'footer',
            style = {
                ['color'] = '#FFFFFF',
                ['background-color'] = 'rgba(255, 0, 0, 0.12)',
                ['border'] = '1px solid rgba(255, 0, 0, 0.35)',
                ['font-size'] = '0.9vw'
            }
        }, function()
            Core.NotifyRightTip(_U('missingDeliveryItems'), 4000)
        end)
    end

    ConfirmationPage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        ShopMenu(station)
    end)

    ConfirmationPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = ConfirmationPage
    })
end
