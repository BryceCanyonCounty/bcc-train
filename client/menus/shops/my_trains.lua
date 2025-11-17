local function ResetTrainAndSpawn(myTrainData, trainCfg, direction, station)
    -- Check regional spawn limits before proceeding
    local canSpawn = Core.Callback.TriggerAwait('bcc-train:CheckTrainSpawn', station)
    if not canSpawn then
        local stationCfg = Stations[station]
        local isWest = stationCfg and stationCfg.train and stationCfg.train.outWest
        local message = isWest and _U('westRegionFull') or _U('eastRegionFull')
        Core.NotifyRightTip(message, 4000)
        return
    end

    -- Check if there's an existing train to cleanup
    if MyTrain and MyTrain ~= 0 and DoesEntityExist(MyTrain) then
        -- Trigger cleanup event and wait for confirmation
        TriggerEvent('bcc-train:ResetTrain')

        -- Wait for cleanup to complete with a timeout
        local attempts = 0
        local maxAttempts = 50 -- 5 seconds at 100ms intervals

        CreateThread(function()
            while attempts < maxAttempts do
                Wait(100)
                attempts = attempts + 1

                -- Check if cleanup is complete
                if not MyTrain or MyTrain == 0 or not DoesEntityExist(MyTrain) then
                    -- Cleanup successful, spawn new train
                    SpawnTrain(myTrainData, trainCfg, direction, station)
                    return
                end
            end

            -- Cleanup failed after timeout
            if attempts >= maxAttempts then
                DBG.Error('Train cleanup failed after 5 seconds. Cannot spawn new train safely.')
                Core.NotifyRightTip(_U('trainCleanupFailed'), 4000)
                return
            end
        end)
    else
        -- No existing train, spawn immediately
        SpawnTrain(myTrainData, trainCfg, direction, station)
    end
end

-- Format sell price display based on currency config
local function FormatSellPrice(trainCfg, currencyType)
    if not trainCfg or not trainCfg.price or type(trainCfg.price) ~= 'table' then
        return 'Price unavailable'
    end

    local price = trainCfg.price
    local sellMultiplier = Config.sellPrice or 0.75

    if currencyType == 0 then -- Cash only
        local sellPrice = math.floor(sellMultiplier * (price.cash or 0))
        return string.format('$%d', sellPrice)

    elseif currencyType == 1 then -- Gold only
        local sellPrice = math.floor(sellMultiplier * (price.gold or 0))
        return string.format('%d %s', sellPrice, _U('currencyGold'))

    elseif currencyType == 2 then -- Both currencies
        local cashSell = math.floor(sellMultiplier * (price.cash or 0))
        local goldSell = math.floor(sellMultiplier * (price.gold or 0))
        local cashStr = string.format('$%d', cashSell)
        local goldStr = string.format('%d %s', goldSell, _U('currencyGold'))
        return cashStr .. ' | ' .. goldStr

    else
        return 'Invalid currency config'
    end
end

function MyTrainsMenu(myTrains, station)
    local MyTrainsPage = TrainShopMenu:RegisterPage('myTrains:page')
    local stationCfg = Stations[station]

    MyTrainsPage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    MyTrainsPage:RegisterElement('subheader', {
        value = _U('myTrainsCat'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    MyTrainsPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    for myTrain, myTrainData in pairs(myTrains) do
        local trainCfg = GetTrainConfig(myTrainData.trainModel)
        if trainCfg then
            -- Use the train name from database (either custom or default train label)
            local displayName = myTrainData.name or trainCfg.label

            MyTrainsPage:RegisterElement('button', {
                label = displayName,
                slot = 'content',
                style = {
                    ['color'] = '#E0E0E0'
                },
            }, function(data)
                DeletePreviewTrain() -- Clean up any existing preview train

                local hash = tonumber(myTrainData.trainModel)
                if hash then
                    PreviewTrain = SpawnPreviewTrainWithDirection(hash, station, false) -- Start with normal direction
                end

                MyTrainActions(myTrainData, trainCfg, station)
            end)
        end
    end

    MyTrainsPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    MyTrainsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    MyTrainsPage:RegisterElement('button', {
        label = _U('openMainMenu'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before going back
        ShopMenu(station)
    end)

    MyTrainsPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before closing
        TrainShopMenu:Close()
    end)

    MyTrainsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = MyTrainsPage
    })
end

function MyTrainActions(myTrainData, trainCfg, station)
    local MyTrainActionsPage = TrainShopMenu:RegisterPage('myTrainActions:page')
    local stationCfg = Stations[station]
    local direction = false --default direction

    MyTrainActionsPage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    -- Use the train name from database (either custom or default train label)
    local displayName = myTrainData.name or trainCfg.label

    MyTrainActionsPage:RegisterElement('subheader', {
        value = displayName,
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    MyTrainActionsPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    MyTrainActionsPage:RegisterElement('button', {
        label = _U('spawnTrain'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        DeletePreviewTrain() -- Clean up preview train before spawning actual train
        TrainShopMenu:Close()
        ResetTrainAndSpawn(myTrainData, trainCfg, direction, station)
    end)

    MyTrainActionsPage:RegisterElement('toggle', {
        label = _U('setTrainDirection'),
        start = false,
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        direction = data.value

        -- If there's a preview train active, update its direction
        if PreviewTrain and DoesEntityExist(PreviewTrain) then
            -- Delete current preview train
            DeletePreviewTrain()

            -- Spawn new preview train with updated direction
            local hash = tonumber(myTrainData.trainModel)
            if hash then
                PreviewTrain = SpawnPreviewTrainWithDirection(hash, station, direction)
            end
        end
    end)

    local inputValue = ''
    MyTrainActionsPage:RegisterElement('input', {
        label = _U('renameTrain'),
        placeholder = _U('enterName'),
        persist = false,
        style = {
            ['color'] = '#E0E0E0',
        }
    }, function(data)
        inputValue = data.value
    end)

    MyTrainActionsPage:RegisterElement('button', {
        label = _U('confirmRename'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        if inputValue and inputValue ~= '' then
            local myTrains = Core.Callback.TriggerAwait('bcc-train:RenameTrain', myTrainData.trainid, inputValue)
            TrainShopMenu:Close()
            if myTrains and #myTrains > 0 then
                MyTrainsMenu(myTrains, station)
            else
                -- If rename failed or no trains, refresh with current data
                myTrains = Core.Callback.TriggerAwait('bcc-train:GetMyTrains')
                if #myTrains > 0 then
                    MyTrainsMenu(myTrains, station)
                else
                    Core.NotifyRightTip(_U('noOwnedTrains'), 4000)
                end
            end
        else
            Core.NotifyRightTip(_U('nameTrain'), 4000)
        end
    end)

    MyTrainActionsPage:RegisterElement('button', {
        label = _U('trainInfo'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        MyTrainSpecsMenu(myTrainData, trainCfg, station)
    end)

    MyTrainActionsPage:RegisterElement('button', {
        label = _U('sellTrain'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        SellTrainMenu(myTrainData, trainCfg, station)
    end)

    MyTrainActionsPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    MyTrainActionsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    MyTrainActionsPage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before going back
        local myTrains = Core.Callback.TriggerAwait('bcc-train:GetMyTrains')
        MyTrainsMenu(myTrains, station)
    end)

    MyTrainActionsPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before closing
        TrainShopMenu:Close()
    end)

    MyTrainActionsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = MyTrainActionsPage
    })
end

function SellTrainMenu(myTrainData, trainCfg, station)
    local SellPage = TrainShopMenu:RegisterPage('sellTrain:page')
    local stationCfg = Stations[station]
    local currencyType = stationCfg.shop.currency
    local selectedCurrency = 'cash' -- Default to cash
    if currencyType == 1 then
        selectedCurrency = 'gold' -- If only gold is allowed, set it
    end

    SellPage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    SellPage:RegisterElement('subheader', {
        value = _U('sellTrain'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    SellPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    SellPage:RegisterElement('textdisplay', {
        value = _U('train') .. trainCfg.label,
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    local priceText = FormatSellPrice(trainCfg, currencyType)
    SellPage:RegisterElement('textdisplay', {
        value = _U('sellPrice') .. priceText,
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    -- Check if train has registered inventory
    local hasInventory = Core.Callback.TriggerAwait('bcc-train:CheckTrainInventory', myTrainData.trainid)
    if hasInventory then
        SellPage:RegisterElement('textdisplay', {
            value = '⚠ ' .. _U('trainInventoryWarning1'),
            slot = 'content',
            style = {
                ['color'] = '#FF6B6B',
                ['font-size'] = '0.75vw',
            }
        })

        SellPage:RegisterElement('textdisplay', {
            value = _U('trainInventoryWarning2'),
            slot = 'content',
            style = {
                ['color'] = '#FF6B6B',
                ['font-size'] = '0.75vw',
            }
        })
    end

    -- Only show currency selector if station allows both currencies
    if currencyType == 2 then
        SellPage:RegisterElement('arrows', {
            label = _U('currency'),
            slot = 'content',
            start = 1,
            options = {
                { display = _U('currencyCash'),  extra = 'cash' },
                { display = _U('currencyGold'),  extra = 'gold' }
            },
            style = {
                ['color'] = '#E0E0E0',
            },
            persist = false,
        }, function(data)
            selectedCurrency = data.value.extra
        end)
    end

    SellPage:RegisterElement('button', {
        label = _U('confirmSale'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        -- Check if train is currently spawned on server
        local isSpawned = Core.Callback.TriggerAwait('bcc-train:IsTrainSpawned', myTrainData.trainid)
        if isSpawned then
            Core.NotifyRightTip(_U('cannotSellSpawnedTrain'), 4000)
            return
        end

        DeletePreviewTrain() -- Clean up preview train before sale
        TriggerServerEvent('bcc-train:SellTrain', myTrainData, selectedCurrency, station)
        ShopMenu(station)
    end)

    SellPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    SellPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    SellPage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        -- Don't delete preview train when going back to train actions
        MyTrainActions(myTrainData, trainCfg, station)
    end)

    SellPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before closing
        TrainShopMenu:Close()
    end)

    SellPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = SellPage
    })
end

function MyTrainSpecsMenu(myTrainData, trainCfg, station)
    local MyTrainSpecsPage = TrainShopMenu:RegisterPage('myTrainSpecs:page')
    local stationCfg = Stations[station]

    MyTrainSpecsPage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    MyTrainSpecsPage:RegisterElement('subheader', {
        value = _U('trainInfo'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    MyTrainSpecsPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    MyTrainSpecsPage:RegisterElement('textdisplay', {
        value = _U('name') .. (myTrainData.name or trainCfg.label),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    MyTrainSpecsPage:RegisterElement('textdisplay', {
        value = _U('model') .. (trainCfg and trainCfg.label or _U('unknownModel')),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    MyTrainSpecsPage:RegisterElement('textdisplay', {
        value = _U('maxSpeed') .. (trainCfg and tostring(trainCfg.maxSpeed) or 'N/A'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    MyTrainSpecsPage:RegisterElement('textdisplay', {
        value = _U('inventory') .. (trainCfg and trainCfg.inventory and tostring(trainCfg.inventory.limit) or 'N/A'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    MyTrainSpecsPage:RegisterElement('textdisplay', {
        value = _U('fuelInfo') .. myTrainData.fuel .. ' / ' .. (trainCfg and trainCfg.fuel and tostring(trainCfg.fuel.maxAmount) or 'N/A'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    MyTrainSpecsPage:RegisterElement('textdisplay', {
        value = _U('conditionInfo') .. myTrainData.condition .. ' / ' .. (trainCfg and trainCfg.condition and tostring(trainCfg.condition.maxAmount) or 'N/A'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    MyTrainSpecsPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    MyTrainSpecsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    MyTrainSpecsPage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        MyTrainActions(myTrainData, trainCfg, station)
    end)

    MyTrainSpecsPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        TrainShopMenu:Close()
    end)

    MyTrainSpecsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = MyTrainSpecsPage
    })
end
