local SortedTrains = {}

local function naturalSort(a, b)
    local function padNum(str)
        return str:gsub('%d+', function(n)
            return string.format('%010d', tonumber(n))
        end)
    end
    return padNum(a) < padNum(b)
end

-- Initialize sorted train lists
local function InitializeSortedTrains()
    DBG.Info('Initializing sorted train lists')
    local categories = {
        cargo = Cargo,
        passenger = Passenger,
        mixed = Mixed,
        special = Special
    }

    for categoryName, categoryCfg in pairs(categories) do
        SortedTrains[categoryName] = {}

        -- Create list of trains with their data
        for trainHash, trainCfg in pairs(categoryCfg) do
            table.insert(SortedTrains[categoryName], {
                hash = trainHash,
                config = trainCfg
            })
        end

        -- Sort by label using natural sort (handles numbers correctly)
        table.sort(SortedTrains[categoryName], function(a, b)
            return naturalSort(a.config.label, b.config.label)
        end)

        DBG.Info(string.format('Category %s: %d trains loaded', categoryName, #SortedTrains[categoryName]))
    end
    DBG.Success('Sorted train lists initialized successfully')
end

-- Initialize sorted lists when script loads
CreateThread(function()
    Wait(100) -- Small delay to ensure train configs are loaded
    InitializeSortedTrains()
end)

-- Format price display based on currency config
local function FormatPrice(trainCfg, currencyType)
    if not trainCfg or not trainCfg.price or type(trainCfg.price) ~= "table" then
        return "Price unavailable"
    end

    local price = trainCfg.price

    if currencyType == 0 then -- Cash only
        return string.format("$%d", price.cash or 0)
    elseif currencyType == 1 then -- Gold only
        return string.format("%d Gold", price.gold or 0)
    elseif currencyType == 2 then -- Both currencies
        local cashStr = string.format("$%d", price.cash or 0)
        local goldStr = string.format("%d Gold", price.gold or 0)
        return cashStr .. " | " .. goldStr
    else
        return "Invalid currency config"
    end
end

function BuyTrainsMenu(station)
    DBG.Info(string.format('Opening buy trains menu for station: %s', tostring(station)))
    local BuyTrainsPage = TrainShopMenu:RegisterPage('buyTrains:page')
    local stationCfg = Stations[station]

    BuyTrainsPage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    BuyTrainsPage:RegisterElement('subheader', {
        value = _U('selectCategory'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    BuyTrainsPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    local trainCategories = {
        { name = _U('cargoCat'),     id = 'cargo' },
        { name = _U('passengerCat'), id = 'passenger' },
        { name = _U('mixedCat'),     id = 'mixed' },
        { name = _U('specialCat'),   id = 'special' },
    }

    for i, category in ipairs(trainCategories) do
        BuyTrainsPage:RegisterElement('button', {
            label = category.name,
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0'
            },
            id = category.id
        }, function(data)
            DeletePreviewTrain() -- Clean up any existing preview train
            TrainsMenu(data.id, station)
        end)
    end

    BuyTrainsPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    BuyTrainsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    BuyTrainsPage:RegisterElement('button', {
        label = _U('openMainMenu'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain()
        ShopMenu(station)
    end)

    BuyTrainsPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain()
        TrainShopMenu:Close()
    end)

    BuyTrainsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = BuyTrainsPage
    })
end

function TrainsMenu(category, station)
    DBG.Info(string.format('Opening trains menu - Category: %s, Station: %s', tostring(category), tostring(station)))
    local TrainsPage = TrainShopMenu:RegisterPage('trains:page')
    local stationCfg = Stations[station]

    TrainsPage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    TrainsPage:RegisterElement('subheader', {
        value = _U('selectTrain'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    TrainsPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    -- Get job-filtered trains for this category
    DBG.Info(string.format('Requesting job-filtered trains for category: %s', tostring(category)))
    local jobFilteredTrains = Core.Callback.TriggerAwait('bcc-train:GetJobFilteredTrains', category)
    if not jobFilteredTrains or next(jobFilteredTrains) == nil then
        DBG.Warning(string.format('No trains available in category %s for player job', tostring(category)))
        TrainsPage:RegisterElement('textdisplay', {
            value = _U('noTrainForJob'),
            slot = 'content',
            style = {
                ['color'] = '#FF6B6B',
                ['text-align'] = 'center'
            }
        })
        return
    end

    DBG.Success(string.format('Received %d job-filtered trains', #jobFilteredTrains or 0))

    -- Create sorted list from job-filtered trains
    local sortedTrains = {}
    for trainHash, trainCfg in pairs(jobFilteredTrains) do
        table.insert(sortedTrains, {
            hash = trainHash,
            config = trainCfg
        })
    end

    -- Sort by label using natural sort
    table.sort(sortedTrains, function(a, b)
        return naturalSort(a.config.label, b.config.label)
    end)

    DBG.Info(string.format('Displaying %d sorted trains in menu', #sortedTrains))

    -- Add sorted trains to menu
    for _, trainData in ipairs(sortedTrains) do
        TrainsPage:RegisterElement('button', {
            label = trainData.config.label,
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0'
            },
            id = trainData.hash
        }, function(data)
            DeletePreviewTrain()
            local hash = data.id
            DBG.Info(string.format('Train selected for preview - Hash: %s', tostring(hash)))
            -- Spawn new preview train using station spawn coordinates with normal direction
            PreviewTrain = SpawnPreviewTrainWithDirection(tonumber(hash), station, false)
            PurchaseMenu(hash, category, station)
        end)
    end

    TrainsPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    TrainsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainsPage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before going back
        BuyTrainsMenu(station)
    end)

    TrainsPage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before closing
        TrainShopMenu:Close()
    end)

    TrainsPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = TrainsPage
    })
end

function PurchaseMenu(modelHash, category, station)
    DBG.Info(string.format('Opening purchase menu - Model: %s, Category: %s, Station: %s', tostring(modelHash), tostring(category), tostring(station)))
    local PurchasePage = TrainShopMenu:RegisterPage('trains:page')
    local stationCfg = Stations[station]
    local currencyType = stationCfg.shop.currency
    local selectedCurrency = 'cash' -- Default to cash
    if currencyType == 1 then
        selectedCurrency = 'gold' -- Force gold if config is gold only
    end
    DBG.Info(string.format('Currency type: %d, Default selection: %s', currencyType, selectedCurrency))

    PurchasePage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    PurchasePage:RegisterElement('subheader', {
        value = _U('trainInfo'),
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    PurchasePage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    local trainCfg = GetTrainConfig(modelHash)
    local priceText = FormatPrice(trainCfg, currencyType)

    PurchasePage:RegisterElement('textdisplay', {
        value = trainCfg and trainCfg.label or _U("unknownTrainName"),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    PurchasePage:RegisterElement('textdisplay', {
        value = _U('price') .. priceText,
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    PurchasePage:RegisterElement('textdisplay', {
        value = _U('inventory') .. (trainCfg and trainCfg.inventory and tostring(trainCfg.inventory.limit) or '100') .. _U('slots'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    PurchasePage:RegisterElement('textdisplay', {
        value = _U('maxSpeed') .. (trainCfg and tostring(trainCfg.maxSpeed) or 'N/A'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0',
            ['font-variant'] = 'small-caps',
            ['font-size'] = '0.83vw',
        }
    })

    -- Only show currency selector if station allows both currencies
    if currencyType == 2 then
        PurchasePage:RegisterElement('arrows', {
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
            DBG.Info(string.format('Currency selection changed to: %s', tostring(selectedCurrency)))
        end)
    end

    local inputValue = ''
    PurchasePage:RegisterElement('input', {
        label = _U('trainName'),
        placeholder = _U('enterName'),
        persist = false,
        style = {
            ['color'] = '#E0E0E0',
        }
    }, function(data)
        inputValue = data.value
    end)

    PurchasePage:RegisterElement('button', {
        label = _U('purchase'),
        slot = 'content',
        style = {
            ['color'] = '#E0E0E0'
        },
        id = modelHash
    }, function(data)
        DeletePreviewTrain()
        local hash = data.id
        local trainName = inputValue and inputValue ~= '' and inputValue or nil -- Send name if provided
        DBG.Info(string.format('Purchase initiated - Hash: %s, Currency: %s, Name: %s', tostring(hash), tostring(selectedCurrency), tostring(trainName or 'default')))
        TriggerServerEvent('bcc-train:BuyTrain', hash, selectedCurrency, trainName, station)
        ShopMenu(station)
    end)

    PurchasePage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    PurchasePage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    PurchasePage:RegisterElement('button', {
        label = _U('back'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before going back
        TrainsMenu(category, station)
    end)

    PurchasePage:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        DeletePreviewTrain() -- Clean up preview train before closing
        TrainShopMenu:Close()
    end)

    PurchasePage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = PurchasePage
    })
end
