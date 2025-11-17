---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

local SEED_VERSION = 1

local ITEMS = {
    { 'bagofcoal', 'Bag Of Coal', 10, 1, 'item_standard', 1, 'Fuel for steam engines' },
    { 'trainoil', 'Train Oil', 10, 1, 'item_standard', 1, 'Oil used for lubricating train parts' },
    { 'dynamitebundle', 'Dynamite Bundle', 10, 1, 'item_standard', 1, 'A bundle of dynamite sticks' },
    { 'lockpick', 'Lockpick', 5, 1, 'item_standard', 1, 'A handy tool used to pick locks' },
}

local UPSERT_SQL = [[
INSERT INTO `items` (`item`, `label`, `limit`, `can_remove`, `type`, `usable`, `desc`)
VALUES (?, ?, ?, ?, ?, ?, ?)
ON DUPLICATE KEY UPDATE `label` = VALUES(`label`), `limit` = VALUES(`limit`), `can_remove` = VALUES(`can_remove`), `type` = VALUES(`type`), `usable` = VALUES(`usable`), `desc` = VALUES(`desc`);
]]

local CREATE_MIGRATIONS_SQL = [[
CREATE TABLE IF NOT EXISTS `resource_migrations` (
  `resource` VARCHAR(128) NOT NULL PRIMARY KEY,
  `version` INT NOT NULL
);
]]

local function hasAwaitMySQL()
    return (exports.oxmysql ~= nil) or (MySQL ~= nil and MySQL.query ~= nil and MySQL.query.await ~= nil) or false
end

local function waitForDB(maxAttempts, delay)
    maxAttempts = maxAttempts or 8
    delay = delay or 500
    for i = 1, maxAttempts do
        if exports.oxmysql then
            local ok = pcall(function() return exports.oxmysql:query_async('SELECT 1') end)
            if ok then return true end
        elseif hasAwaitMySQL() then
            local ok = pcall(function() return MySQL.query.await('SELECT 1') end)
            if ok then return true end
        else
            if exports and exports.mysql then
                return true
            end
        end
        Wait(delay)
        delay = delay * 2
    end
    return false
end

local function dbExecuteAwait(sql, params)
    if exports.oxmysql then
        return exports.oxmysql:update_async(sql, params or {})
    elseif hasAwaitMySQL() then
        return MySQL.update.await(sql, params)
    end
    local done, result = false, nil
    local db = exports and exports.mysql or nil
    if not db then error('No DB available') end
    db:execute(sql, params or {}, function(res)
        result = res
        done = true
    end)
    local tick = 0
    while not done and tick < 100 do
        Wait(50)
        tick = tick + 1
    end
    return result
end

local function dbQueryAwait(sql, params)
    if exports.oxmysql then
        return exports.oxmysql:query_async(sql, params or {})
    elseif hasAwaitMySQL() then
        return MySQL.query.await(sql, params)
    end
    local done, result = false, nil
    local db = exports and exports.mysql or nil
    if not db then error('No DB available') end
    db:execute(sql, params or {}, function(res)
        result = res
        done = true
    end)
    local tick = 0
    while not done and tick < 100 do
        Wait(50)
        tick = tick + 1
    end
    return result
end

local function ensureTrainSchema()
    local createTrain = [[
    CREATE TABLE IF NOT EXISTS `bcc_player_trains` (
        `trainid` int(11) NOT NULL PRIMARY KEY AUTO_INCREMENT,
        `charidentifier` int(11) NOT NULL,
        `trainModel` varchar(50) NOT NULL,
        `name` varchar(100) DEFAULT NULL,
        `fuel` int(11) NOT NULL,
        `condition` int(11) NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]
    if exports.oxmysql then
        exports.oxmysql:update_async(createTrain)
    elseif hasAwaitMySQL() then
        MySQL.update.await(createTrain)
    else
        dbExecuteAwait(createTrain)
    end
end

local function getMigrationVersion()
    if not waitForDB() then return 0 end
    if exports.oxmysql then
        exports.oxmysql:update_async(CREATE_MIGRATIONS_SQL)
        local rows = exports.oxmysql:query_async('SELECT version FROM resource_migrations WHERE resource = ?', { GetCurrentResourceName() })
        if rows and rows[1] and rows[1].version then
            return tonumber(rows[1].version) or 0
        end
        return 0
    elseif hasAwaitMySQL() then
        MySQL.update.await(CREATE_MIGRATIONS_SQL)
        local rows = MySQL.query.await('SELECT version FROM resource_migrations WHERE resource = ?', { GetCurrentResourceName() })
        if rows and rows[1] and rows[1].version then
            return tonumber(rows[1].version) or 0
        end
        return 0
    else
        dbExecuteAwait(CREATE_MIGRATIONS_SQL)
        local rows = dbQueryAwait('SELECT version FROM resource_migrations WHERE resource = ?', { GetCurrentResourceName() })
        if rows and rows[1] and rows[1].version then
            return tonumber(rows[1].version) or 0
        end
        return 0
    end
end

local function setMigrationVersion(v)
    if exports.oxmysql then
        exports.oxmysql:update_async('INSERT INTO resource_migrations(resource, version) VALUES(?, ?) ON DUPLICATE KEY UPDATE version = VALUES(version);', { GetCurrentResourceName(), v })
    elseif hasAwaitMySQL() then
        MySQL.update.await('INSERT INTO resource_migrations(resource, version) VALUES(?, ?) ON DUPLICATE KEY UPDATE version = VALUES(version);', { GetCurrentResourceName(), v })
    else
        dbExecuteAwait('INSERT INTO resource_migrations(resource, version) VALUES(?, ?) ON DUPLICATE KEY UPDATE version = VALUES(version);', { GetCurrentResourceName(), v })
    end
end

-----------------------------------------------------
-- Train Model Migration System
-----------------------------------------------------

-- Model name to hex hash mapping based on mission_trains table
local MODEL_NAME_TO_HEX = {
    ['appleseed_config'] = '0x8EAC625C',
    ['bountyhunter_config'] = '0xF9B038FC',
    ['dummy_engine_config'] = '0x26509FBB',
    ['engine_config'] = '0x3260CE89',
    ['gunslinger3_config'] = '0x3D72571D',
    ['gunslinger4_config'] = '0x5AA369CA',
    ['prisoner_escort_config'] = '0x515E31ED',
    ['winter4_config'] = '0x487B2BE7',
    ['ghost_train_config'] = '0x0E62D710',
    ['handcart_config'] = '0x3EDA466D',
    ['industry2_config'] = '0x767DEB32',
    ['trolley_config'] = '0xBF69518F',
    ['minecart_config'] = '0xC75AA08C',
}

-- Migrate train models from string names to hex hashes
local function migrateTrainModels()
    if not waitForDB() then
        DBG.Warning('Database not available; cannot migrate train models.')
        return
    end

    -- Check if old train table exists and new one exists
    local oldTableExists = dbQueryAwait("SHOW TABLES LIKE 'train'")
    local newTableExists = dbQueryAwait("SHOW TABLES LIKE 'bcc_player_trains'")

    -- Handle different migration scenarios
    if oldTableExists and #oldTableExists > 0 then
        if not newTableExists or #newTableExists == 0 then
            -- Scenario 1: Old table exists, new doesn't - rename it
            DBG.Info('Renaming train table to bcc_player_trains')
            local renameResult = dbExecuteAwait('RENAME TABLE train TO bcc_player_trains')
            if renameResult then
                DBG.Success('Successfully renamed train table to bcc_player_trains')
            else
                DBG.Error('Failed to rename train table to bcc_player_trains')
                return
            end
        else
            -- Scenario 2: Both tables exist - copy data from old to new, then drop old
            DBG.Info('Both train and bcc_player_trains tables exist - migrating data')

            -- Check if old table has data
            local oldData = dbQueryAwait('SELECT COUNT(*) as count FROM train')
            if oldData and oldData[1] and oldData[1].count > 0 then
                DBG.Info(string.format('Found %d records in old train table to migrate', oldData[1].count))

                -- Copy data from old table to new table
                local copyResult = dbExecuteAwait([[
                    INSERT INTO bcc_player_trains (charidentifier, trainModel, fuel, `condition`)
                    SELECT charidentifier, trainModel, fuel, `condition` FROM train
                    ON DUPLICATE KEY UPDATE trainModel = VALUES(trainModel)
                ]])

                if copyResult then
                    DBG.Success('Successfully copied data from train to bcc_player_trains')

                    -- Drop the old table
                    local dropResult = dbExecuteAwait('DROP TABLE train')
                    if dropResult then
                        DBG.Success('Successfully dropped old train table')
                    else
                        DBG.Warning('Failed to drop old train table - you may want to drop it manually')
                    end
                else
                    DBG.Error('Failed to copy data from old train table')
                    return
                end
            else
                DBG.Info('Old train table is empty - dropping it')
                local dropResult = dbExecuteAwait('DROP TABLE train')
                if dropResult then
                    DBG.Success('Successfully dropped empty old train table')
                else
                    DBG.Warning('Failed to drop old train table')
                end
            end
        end
    elseif not newTableExists or #newTableExists == 0 then
        DBG.Info('No train tables exist; skipping migration.')
        return
    else
        DBG.Info('bcc_player_trains table already exists, old train table not found')
    end

    -- Get all train records that need migration (not already hex format)
    local trainRecords = dbQueryAwait('SELECT trainid, trainModel FROM bcc_player_trains WHERE trainModel NOT LIKE "0x%"')
    if not trainRecords or #trainRecords == 0 then
        DBG.Info('No train models need migration.')
        return
    end

    DBG.Info(string.format('Found %d train records to migrate', #trainRecords))

    local migrated = 0
    local skipped = 0

    for _, record in ipairs(trainRecords) do
        local trainId = record.trainid
        local currentModel = record.trainModel

        if MODEL_NAME_TO_HEX[currentModel] then
            local hexHash = MODEL_NAME_TO_HEX[currentModel]
            local updateResult = dbExecuteAwait('UPDATE bcc_player_trains SET trainModel = ? WHERE trainid = ?', { hexHash, trainId })

            if updateResult then
                DBG.Info(string.format('Migrated train ID %d: "%s" -> %s', trainId, currentModel, hexHash))
                migrated = migrated + 1
            else
                DBG.Error(string.format('Failed to migrate train ID %d', trainId))
            end
        else
            DBG.Warning(string.format('Unknown model "%s" for train ID %d - skipping', currentModel, trainId))
            skipped = skipped + 1
        end
    end

    DBG.Success(string.format('Migration complete: %d migrated, %d skipped', migrated, skipped))
end

-----------------------------------------------------
-- Database Schema Migrations
-----------------------------------------------------

local function addNameColumnToTrains()
    if not waitForDB() then
        DBG.Warning('Database not available; cannot add name column.')
        return
    end

    -- Check if bcc_player_trains table exists
    local tableExists = dbQueryAwait("SHOW TABLES LIKE 'bcc_player_trains'")
    if not tableExists or #tableExists == 0 then
        DBG.Info('bcc_player_trains table does not exist; skipping name column migration.')
        return
    end

    -- Check if name column already exists
    local columnExists = dbQueryAwait("SHOW COLUMNS FROM bcc_player_trains LIKE 'name'")
    if columnExists and #columnExists > 0 then
        DBG.Info('Name column already exists in bcc_player_trains table.')
        return
    end

    -- Add the name column
    local addColumnResult = dbExecuteAwait('ALTER TABLE bcc_player_trains ADD COLUMN name VARCHAR(100) DEFAULT NULL AFTER trainModel')
    if addColumnResult then
        DBG.Success('Successfully added name column to bcc_player_trains table')

        -- Update existing trains with default names based on their train config
        local existingTrains = dbQueryAwait('SELECT trainid, trainModel FROM bcc_player_trains WHERE name IS NULL')
        if existingTrains and #existingTrains > 0 then
            DBG.Info(string.format('Setting default names for %d existing trains', #existingTrains))

            for _, train in ipairs(existingTrains) do
                local trainConfig = (Cargo and Cargo[train.trainModel]) or
                                 (Passenger and Passenger[train.trainModel]) or
                                 (Mixed and Mixed[train.trainModel]) or
                                 (Special and Special[train.trainModel])

                local defaultName = trainConfig and trainConfig.label or 'Unknown Train'
                dbExecuteAwait('UPDATE bcc_player_trains SET name = ? WHERE trainid = ?', { defaultName, train.trainid })
            end

            DBG.Success('Default names set for existing trains')
        end
    else
        DBG.Error('Failed to add name column to bcc_player_trains table')
    end
end

local function runDatabaseMigrations()
    if not waitForDB() then
        DBG.Warning('Database not available; cannot run migrations.')
        return
    end

    local currentVersion = 0
    local ok, err = pcall(function() currentVersion = getMigrationVersion() end)
    if not ok then
        DBG.Warning(string.format('Failed to get migration version: %s', tostring(err)))
        currentVersion = 0
    end

    DBG.Info(string.format('Current database version: %d, Target version: %d', currentVersion, SEED_VERSION))

    -- Migration version 1: Complete train system setup (table rename + hex hashes + name column)
    if currentVersion < 1 then
        DBG.Info('Running migration 1: Table rename, train model hex hash conversion and name column setup')

        -- Run train model migration (includes table rename)
        migrateTrainModels()

        -- Add name column if it doesn't exist (for existing installations)
        addNameColumnToTrains()
    end    -- Set the current version
    pcall(function() setMigrationVersion(SEED_VERSION) end)
    DBG.Success(string.format('Database migrations complete. Version set to %d', SEED_VERSION))
end

local function seedItems(force)
    if not Config then
        DBG.Warning('Config missing; cannot determine autoSeedDatabase setting. Skipping seeding.')
        return
    end
    if Config.autoSeedDatabase == false and not force then
        DBG.Info('autoSeedDatabase disabled in config; skipping DB seeding.')
        return
    end
    if not waitForDB() then
        DBG.Warning('Database not available after retries; skipping seeding.')
        return
    end
    local currentVersion = 0
    local ok, err = pcall(function() currentVersion = getMigrationVersion() end)
    if not ok then
        DBG.Warning(string.format('Failed to get migration version: %s', tostring(err)))
        currentVersion = 0
    end
    if currentVersion >= SEED_VERSION and not force then
        DBG.Info(string.format('Items already seeded (version %s), skipping.', tostring(currentVersion)))
        return
    end
    DBG.Info('Seeding items...')
    for _, item in ipairs(ITEMS) do
        local ok2, res = pcall(function()
            return dbExecuteAwait(UPSERT_SQL, { item[1], item[2], item[3], item[4], item[5], item[6], item[7] })
        end)
        if not ok2 then
            DBG.Error(string.format('Failed to upsert item %s: %s', tostring(item[1]), tostring(res)))
        else
            DBG.Info(string.format('Upserted item: %s', tostring(item[1])))
        end
    end
    pcall(function() setMigrationVersion(SEED_VERSION) end)
    DBG.Info(string.format('Seeding complete; set seed version to %s', tostring(SEED_VERSION)))
end

RegisterCommand('bcc-train:seed', function(source, args, raw)
    if source ~= 0 then
        DBG.Warning('bcc-train:seed can only be run from server console')
        return
    end
    seedItems(true)
end, true)

RegisterCommand('bcc-train:verify', function(source, args, raw)
    if source ~= 0 then
        DBG.Warning('bcc-train:verify can only be run from server console')
        return
    end
    if not waitForDB() then
        DBG.Warning('Database not available; cannot verify items.')
        return
    end
    local missing = {}
    for _, item in ipairs(ITEMS) do
        local rows = dbQueryAwait('SELECT item FROM items WHERE item = ?', { item[1] })
        if not rows or #rows == 0 then
            table.insert(missing, item[1])
        end
    end
    if #missing == 0 then
        DBG.Info('All items present in the items table.')
    else
        DBG.Warning(string.format('Missing items: %s', table.concat(missing, ', ')))
    end
end, true)

RegisterCommand('bcc-train:migrate', function(source, args, raw)
    if source ~= 0 then
        DBG.Warning('bcc-train:migrate can only be run from server console')
        return
    end
    runDatabaseMigrations()
end, true)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    CreateThread(function()
        Wait(1000)

        -- Run database migrations FIRST (this handles table creation/rename)
        local migrationOk, migrationErr = pcall(runDatabaseMigrations)
        if not migrationOk then
            DBG.Warning(string.format('Failed to run database migrations: %s', tostring(migrationErr)))
        end

        -- Only ensure schema if migration didn't handle it
        local tableExists = dbQueryAwait("SHOW TABLES LIKE 'bcc_player_trains'")
        if not tableExists or #tableExists == 0 then
            local ok, err = pcall(ensureTrainSchema)
            if not ok then
                DBG.Warning(string.format('Failed to ensure train schema: %s', tostring(err)))
            end
        end

        seedItems(false)
    end)
end)
