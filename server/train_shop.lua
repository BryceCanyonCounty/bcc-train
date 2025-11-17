-- Train shop: buying, selling, renaming, and train management

-- Check if player has required job and grade for a shop
local function CheckPlayerJob(charJob, jobGrade, shop)
    -- Validate shop configuration exists
    local stationCfg = Stations[shop]
    if not stationCfg or not stationCfg.shop or not stationCfg.shop.jobs then
        DBG.Error(string.format('Invalid shop configuration for job check: %s', tostring(shop)))
        return false
    end

    local jobs = stationCfg.shop.jobs
    for _, job in ipairs(jobs) do
        if charJob == job.name and jobGrade >= job.grade then
            return true
        end
    end
    return false
end

-- Callback to check if player has required job for shop access
Core.Callback.Register('bcc-train:CheckJob', function(source, cb, shop)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(false)
    end

    -- Validate shop parameter
    if not shop or type(shop) ~= 'string' then
        DBG.Error(string.format('Invalid shop parameter received from source: %d', src))
        return cb(false)
    end

    local character = user.getUsedCharacter
    local charJob = character.job
    local jobGrade = character.jobGrade

    DBG.Info(string.format('Checking job for user: charJob=%s, jobGrade=%s', charJob, jobGrade))

    if not charJob or not CheckPlayerJob(charJob, jobGrade, shop) then
        DBG.Warning('User does not have the required job or grade.')
        Core.NotifyRightTip(src, _U('needJob'), 4000)
        return cb(false)
    end

    DBG.Success('User has the required job and grade.')
    return cb(true)
end)

-- Get job-filtered trains for buy menu
Core.Callback.Register('bcc-train:GetJobFilteredTrains', function(source, cb, category)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb({})
    end

    local character = user.getUsedCharacter
    local playerJob = character.job

    local categoryMap = {
        cargo = Cargo,
        passenger = Passenger,
        mixed = Mixed,
        special = Special
    }

    local categoryTrains = categoryMap[category]
    if not categoryTrains then
        return cb({})
    end

    local filteredTrains = {}
    for trainHash, trainCfg in pairs(categoryTrains) do
        -- Check if train has job requirements
        if trainCfg.job and #trainCfg.job > 0 then
            -- Check if player has required job
            local hasRequiredJob = false
            for _, requiredJob in ipairs(trainCfg.job) do
                if playerJob == requiredJob then
                    hasRequiredJob = true
                    break
                end
            end

            if hasRequiredJob then
                filteredTrains[trainHash] = trainCfg
            end
        else
            -- No job requirements, available to all
            filteredTrains[trainHash] = trainCfg
        end
    end

    return cb(filteredTrains)
end)

-- Get player's owned trains
Core.Callback.Register('bcc-train:GetMyTrains', function(source, cb)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb({})
    end

    local character = user.getUsedCharacter
    local myTrains = MySQL.query.await('SELECT * FROM `bcc_player_trains` WHERE `charidentifier` = ?',
        { character.charIdentifier })
    if myTrains and #myTrains > 0 then
        return cb(myTrains)
    else
        return cb({})
    end
end)

-- Event to handle train purchase
RegisterNetEvent('bcc-train:BuyTrain', function(trainHash, clientCurrency, trainName, station)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    local character = user.getUsedCharacter

    -- Check operation cooldown to prevent rapid duplicate purchases
    local buyCooldown = (Config.rateLimiting and Config.rateLimiting.purchaseCooldown) or 5
    local canOperate, timeRemaining = CheckOperationCooldown(src, 'trainPurchase', buyCooldown)
    if not canOperate then
        Core.NotifyRightTip(src, _U('pleaseWaitSeconds') .. ': ' .. tostring(timeRemaining) .. 's', 4000)
        return
    end

    DBG.Info(string.format('BuyTrain called with trainHash: %s, clientCurrency: %s, trainName: %s, station: %s',
        tostring(trainHash), tostring(clientCurrency), tostring(trainName), tostring(station)))

    -- Validate trainHash parameter - should be hex format
    if not trainHash or type(trainHash) ~= 'string' then
        DBG.Error('Invalid train hash provided for purchase')
        return
    end

    -- Validate hex hash format (0x followed by hex characters)
    if not trainHash:match('^0x[0-9A-Fa-f]+$') then
        DBG.Error('Invalid train hash format - expected hex format (0x...)')
        return
    end

    -- Validate clientCurrency parameter if provided
    if clientCurrency and type(clientCurrency) ~= 'string' then
        DBG.Error('Invalid client currency type provided')
        return
    end

    if clientCurrency and clientCurrency ~= 'cash' and clientCurrency ~= 'gold' then
        DBG.Error('Invalid client currency value - must be "cash" or "gold"')
        return
    end

    -- Validate trainName parameter if provided
    if trainName and type(trainName) ~= 'string' then
        DBG.Error('Invalid train name type provided')
        return
    end

    -- Atomic check for maximum train limit using database transaction
    local currentTrains = MySQL.query.await('SELECT COUNT(*) as count FROM `bcc_player_trains` WHERE `charidentifier` = ? FOR UPDATE', { character.charIdentifier })
    local trainCount = currentTrains and currentTrains[1] and currentTrains[1].count or 0

    if trainCount >= Config.maxTrains then
        Core.NotifyRightTip(src, _U('maxTrainsReached'), 4000)
        DBG.Info(string.format('Player %s has reached max train limit (%d/%d)', character.charIdentifier, trainCount,
            Config.maxTrains))
        return
    end

    -- Get train configuration from hash first (needed for default name)
    local trainCfg = GetTrainConfig(trainHash)
    if not trainCfg then
        DBG.Error(string.format('Train configuration not found for hash: %s', tostring(trainHash)))
        return
    end

    -- Check job requirements
    if trainCfg.job and #trainCfg.job > 0 then
        local hasRequiredJob = false
        for _, requiredJob in ipairs(trainCfg.job) do
            if character.job == requiredJob then
                hasRequiredJob = true
                break
            end
        end

        if not hasRequiredJob then
            Core.NotifyRightTip(src, _U('jobRequiredForTrain'), 4000)
            DBG.Warning(string.format('Player %s attempted to buy job-restricted train %s without required job',
                character.charIdentifier, trainHash))
            return
        end
    end

    -- Sanitize train name or use train label as default
    local finalTrainName = trainCfg.label -- Default to train label
    if trainName and trainName ~= '' then
        -- Remove potentially dangerous characters, special symbols, and limit length
        local sanitized = trainName:gsub('[^%w%s%-_]', ''):gsub('%s+', ' '):sub(1, 50):match('^%s*(.-)%s*$')
        if sanitized and sanitized ~= '' then
            finalTrainName = sanitized
        end
        -- If sanitization results in empty string, keep the default train label
    end

    DBG.Info(string.format('Found train configuration: %s', json.encode(trainCfg)))

    local trainPrice = trainCfg.price

    -- Validate that price is in table format (cash/gold structure)
    if not trainPrice or type(trainPrice) ~= 'table' then
        DBG.Error('Invalid price configuration - table format required with cash/gold properties')
        return
    end

    -- Get station currency configuration
    if not station or not Stations[station] then
        DBG.Error('Invalid station provided for train purchase')
        return
    end

    local stationCurrencyType = Stations[station].shop.currency

    -- Determine price and currency based on station currency and client selection
    local price = 0
    local currency = 0 -- 0 for cash, 1 for gold

    if stationCurrencyType == 0 then
        -- Cash only
        if not trainPrice.cash then
            DBG.Error('Invalid price configuration for cash-only mode - missing cash property')
            return
        end
        price = trainPrice.cash
        currency = 0
    elseif stationCurrencyType == 1 then
        -- Gold only
        if not trainPrice.gold then
            DBG.Error('Invalid price configuration for gold-only mode - missing gold property')
            return
        end
        price = trainPrice.gold
        currency = 1
    elseif stationCurrencyType == 2 then
        -- Both currencies - use client selection (no fallback)
        if clientCurrency == 'gold' then
            if not trainPrice.gold then
                DBG.Error('Train does not support gold payment')
                Core.NotifyRightTip(src, _U('cannotPurchaseWithGold'), 4000)
                return
            end
            price = trainPrice.gold
            currency = 1
        elseif clientCurrency == 'cash' then
            if not trainPrice.cash then
                DBG.Error('Train does not support cash payment')
                Core.NotifyRightTip(src, _U('cannotPurchaseWithCash'), 4000)
                return
            end
            price = trainPrice.cash
            currency = 0
        else
            -- Invalid currency selection - default to cash but validate it exists
            if not trainPrice.cash then
                DBG.Error('Invalid currency selection and no cash price available')
                Core.NotifyRightTip(src, _U('invalidPaymentMethod'), 4000)
                return
            end
            price = trainPrice.cash
            currency = 0
        end
    else
        DBG.Error(string.format('Invalid currency configuration for station %s: %s', tostring(station),
            tostring(stationCurrencyType)))
        return
    end

    -- Check if player has enough currency
    if currency == 0 and character.money < price then
        Core.NotifyRightTip(src, _U('notEnoughMoney'), 4000)
        return
    end
    if currency == 1 and character.gold < price then
        Core.NotifyRightTip(src, _U('notEnoughGold'), 4000)
        return
    end

    -- Store the hash key and name in the database
    MySQL.query.await(
        'INSERT INTO `bcc_player_trains` (`charidentifier`, `trainModel`, `name`, `fuel`, `condition`) VALUES (?, ?, ?, ?, ?)',
        { character.charIdentifier, trainHash, finalTrainName, trainCfg.fuel.maxAmount, trainCfg.condition.maxAmount })

    character.removeCurrency(currency, price)

    Core.NotifyRightTip(src, _U('trainBought'), 4000)

    local currencyText = currency == 0 and 'Cash' or 'Gold'
    local trainDisplayName = finalTrainName -- Use the final train name (custom or default)

    Discord:sendMessage(
        Config.webhook.link,
        _U('charNameWeb') ..
        character.firstname ..
        ' ' ..
        character.lastname ..
        _U('charIdentWeb') ..
        character.identifier ..
        _U('charIdWeb') ..
        character.charIdentifier ..
        _U('boughtTrainWeb') ..
        trainDisplayName ..
        _U('charPriceWeb') ..
        price .. ' ' .. currencyText)
end)

-- Event to handle train sale
RegisterNetEvent('bcc-train:SellTrain', function(myTrainData, clientCurrency, station)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return
    end

    local character = user.getUsedCharacter

    -- Check operation cooldown to prevent rapid sell spam
    local sellCooldown = (Config.rateLimiting and Config.rateLimiting.sellCooldown) or 5
    local canOperate, timeRemaining = CheckOperationCooldown(src, 'trainSell', sellCooldown)
    if not canOperate then
        Core.NotifyRightTip(src, _U('pleaseWaitSeconds') .. ': ' .. tostring(timeRemaining) .. 's', 4000)
        return
    end

    DBG.Info(string.format('SellTrain called with trainModel: %s, clientCurrency: %s, station: %s',
        tostring(myTrainData and myTrainData.trainModel), tostring(clientCurrency), tostring(station)))

    -- Validate myTrainData parameter
    if not myTrainData or type(myTrainData) ~= 'table' then
        DBG.Error('Invalid train data provided for sale')
        return
    end

    if not myTrainData.trainModel or type(myTrainData.trainModel) ~= 'string' then
        DBG.Error('Invalid train model in train data')
        return
    end

    if not myTrainData.trainid then
        DBG.Error('Missing train ID in train data')
        return
    end

    -- Validate trainid is numeric
    local numericTrainId = tonumber(myTrainData.trainid)
    if not numericTrainId or numericTrainId <= 0 then
        DBG.Error('Invalid train ID format')
        return
    end

    -- Validate clientCurrency parameter
    if clientCurrency and type(clientCurrency) ~= 'string' then
        DBG.Error('Invalid client currency type provided')
        return
    end

    if clientCurrency and clientCurrency ~= 'cash' and clientCurrency ~= 'gold' then
        DBG.Error('Invalid client currency value - must be "cash" or "gold"')
        return
    end

    -- Validate train ownership
    if not ValidateTrainOwnership(src, numericTrainId) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return
    end

    -- Check if train is currently spawned (prevents orphaned entities)
    for _, train in ipairs(ActiveTrains) do
        if train.id == numericTrainId and train.owner == src then
            Core.NotifyRightTip(src, _U('cannotSellSpawnedTrain'), 4000)
            DBG.Warning(string.format('Player %s attempted to sell active train ID %d', character.charIdentifier, numericTrainId))
            return
        end
    end

    local trainModel = myTrainData.trainModel
    local trainCfg = GetTrainConfig(trainModel)

    if not trainCfg then
        DBG.Error(string.format('Train configuration not found for model: %s', trainModel))
        return
    end

    -- Validate that price is in table format (cash/gold structure)
    local trainPrice = trainCfg.price
    if not trainPrice or type(trainPrice) ~= 'table' then
        DBG.Error('Invalid price configuration - table format required with cash/gold properties')
        return
    end

    -- Get station currency configuration
    if not station or not Stations[station] then
        DBG.Error('Invalid station provided for train sale')
        return
    end

    local stationCurrencyType = Stations[station].shop.currency

    -- Determine sell price and currency based on station currency and client selection
    local sellPrice = 0
    local currency = 0 -- 0 for cash, 1 for gold
    local sellMultiplier = Config.sellPrice or 0.75

    if stationCurrencyType == 0 then
        -- Cash only
        if not trainPrice.cash then
            DBG.Error('Invalid price configuration for cash-only mode - missing cash property')
            return
        end
        sellPrice = math.floor(sellMultiplier * trainPrice.cash)
        currency = 0
    elseif stationCurrencyType == 1 then
        -- Gold only
        if not trainPrice.gold then
            DBG.Error('Invalid price configuration for gold-only mode - missing gold property')
            return
        end
        sellPrice = math.floor(sellMultiplier * trainPrice.gold)
        currency = 1
    elseif stationCurrencyType == 2 then
        -- Both currencies - use client selection (no fallback)
        if clientCurrency == 'gold' then
            if not trainPrice.gold then
                DBG.Error('Train does not support gold payment')
                Core.NotifyRightTip(src, _U('cannotSellForGold'), 4000)
                return
            end
            sellPrice = math.floor(sellMultiplier * trainPrice.gold)
            currency = 1
        elseif clientCurrency == 'cash' then
            if not trainPrice.cash then
                DBG.Error('Train does not support cash payment')
                Core.NotifyRightTip(src, _U('cannotSellForCash'), 4000)
                return
            end
            sellPrice = math.floor(sellMultiplier * trainPrice.cash)
            currency = 0
        else
            -- Invalid currency selection - default to cash but validate it exists
            if not trainPrice.cash then
                DBG.Error('Invalid currency selection and no cash price available')
                Core.NotifyRightTip(src, _U('invalidPaymentMethod'), 4000)
                return
            end
            sellPrice = math.floor(sellMultiplier * trainPrice.cash)
            currency = 0
        end
    else
        DBG.Error(string.format('Invalid currency configuration for station %s: %s', tostring(station),
            tostring(stationCurrencyType)))
        return
    end

    character.addCurrency(currency, sellPrice)

    -- Only delete the train from database after successful payment
    MySQL.query.await('DELETE FROM `bcc_player_trains` WHERE `charidentifier` = ? AND `trainid` = ?',
        { character.charIdentifier, myTrainData.trainid })
    DBG.Info(string.format('Deleted train ID %s for character %s', tostring(myTrainData.trainid),
        tostring(character.charIdentifier)))

    local currencyText = currency == 0 and 'Cash' or 'Gold'
    Core.NotifyRightTip(src, _U('soldTrain') .. tostring(sellPrice) .. ' ' .. currencyText, 4000)

    Discord:sendMessage(
        Config.webhook.link,
        _U('charNameWeb') ..
        character.firstname ..
        ' ' ..
        character.lastname ..
        _U('charIdentWeb') ..
        character.identifier ..
        _U('charIdWeb') ..
        character.charIdentifier ..
        _U('soldTrainWeb') ..
        trainCfg.label ..
        _U('charPriceWeb') ..
        tostring(sellPrice) .. ' ' .. currencyText)
end)

-- Callback to check if train is currently spawned
Core.Callback.Register('bcc-train:IsTrainSpawned', function(source, cb, trainId)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(false)
    end

    -- Validate trainId parameter
    local numericTrainId = tonumber(trainId)
    if not numericTrainId or numericTrainId <= 0 then
        DBG.Error('Invalid train ID provided for spawn check')
        return cb(false)
    end

    -- Check if train is currently spawned
    for _, train in ipairs(ActiveTrains) do
        if train.id == numericTrainId and train.owner == src then
            DBG.Info(string.format('Train ID %d is currently spawned for player %s', numericTrainId, src))
            return cb(true)
        end
    end

    return cb(false)
end)

-- Callback to check if train inventory is registered
Core.Callback.Register('bcc-train:CheckTrainInventory', function(source, cb, trainId)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(false)
    end

    -- Validate trainId parameter
    local numericTrainId = tonumber(trainId)
    if not numericTrainId or numericTrainId <= 0 then
        DBG.Error('Invalid train ID provided for inventory check')
        return cb(false)
    end

    -- Validate train ownership
    if not ValidateTrainOwnership(src, numericTrainId) then
        return cb(false)
    end

    -- Check if train inventory is registered
    local inventoryId = 'Train_' .. tostring(numericTrainId) .. '_bcc-traininv'
    local isRegistered = exports.vorp_inventory:isCustomInventoryRegistered(inventoryId)
    
    DBG.Info(string.format('Inventory check for train ID %d: %s', numericTrainId, tostring(isRegistered)))
    return cb(isRegistered)
end)

-- Callback to handle train renaming
Core.Callback.Register('bcc-train:RenameTrain', function(source, cb, trainId, newName)
    local src = source
    local user = Core.getUser(src)

    if not user then
        DBG.Error(string.format('User not found for source: %s', tostring(src)))
        return cb(false)
    end

    -- Check operation cooldown to prevent rename spam
    local renameCooldown = (Config.rateLimiting and Config.rateLimiting.renameCooldown) or 10
    local canOperate, timeRemaining = CheckOperationCooldown(src, 'trainRename', renameCooldown)
    if not canOperate then
        Core.NotifyRightTip(src, _U('pleaseWaitSeconds') .. ': ' .. tostring(timeRemaining) .. 's', 4000)
        return cb(false)
    end

    -- Validate trainId parameter
    if not trainId or type(trainId) ~= 'number' then
        DBG.Error('Invalid train ID provided for rename')
        return cb(false)
    end

    -- Validate newName parameter
    if not newName or type(newName) ~= 'string' then
        DBG.Error('Invalid train name provided for rename')
        return cb(false)
    end

    local character = user.getUsedCharacter

    -- Validate train ownership
    if not ValidateTrainOwnership(src, trainId) then
        Core.NotifyRightTip(src, _U('notYourTrain'), 4000)
        return cb(false)
    end

    -- Get current train data for default name fallback
    local trainData = MySQL.query.await(
        'SELECT trainModel FROM `bcc_player_trains` WHERE `charidentifier` = ? AND `trainid` = ?',
        { character.charIdentifier, trainId })
    if not trainData or #trainData == 0 then
        DBG.Error('Train not found in database')
        return cb(false)
    end

    local trainModel = trainData[1].trainModel
    local trainCfg = GetTrainConfig(trainModel)
    if not trainCfg then
        DBG.Error(string.format('Train configuration not found for model: %s', tostring(trainModel)))
        return cb(false)
    end

    -- Sanitize train name or use train label as default
    local finalTrainName = trainCfg.label -- Default to train label
    if newName and newName ~= '' then
        -- Remove potentially dangerous characters, special symbols, and limit length
        local sanitized = newName:gsub('[^%w%s%-_]', ''):gsub('%s+', ' '):sub(1, 50):match('^%s*(.-)%s*$')
        if sanitized and sanitized ~= '' then
            finalTrainName = sanitized
        end
        -- If sanitization results in empty string, keep the default train label
    end

    -- Update the train name in the database
    local success = MySQL.query.await(
        'UPDATE `bcc_player_trains` SET `name` = ? WHERE `charidentifier` = ? AND `trainid` = ?',
        { finalTrainName, character.charIdentifier, trainId })

    if success then
        Core.NotifyRightTip(src, _U('trainRenamed'), 4000)
        DBG.Info(string.format('Player %s renamed train ID %d to: %s', character.charIdentifier, trainId, finalTrainName))
        -- Return updated train list to avoid separate query
        local myTrains = MySQL.query.await('SELECT * FROM `bcc_player_trains` WHERE `charidentifier` = ?',
            { character.charIdentifier })
        return cb(myTrains or {})
    else
        Core.NotifyRightTip(src, _U('failedRename'), 4000)
        DBG.Error(string.format('Failed to rename train ID %d for player %s', trainId, character.charIdentifier))
        return cb(false)
    end
end)
