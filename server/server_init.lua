-- Server initialization: core setup, helper functions, and shared state

Core = exports.vorp_core:GetCore()
BccUtils = exports['bcc-utils'].initiate()
---@type BCCTrainDebugLib
DBG = BCCTrainDebug

TrainRobberyAlert = exports['bcc-job-alerts']:RegisterAlert(Config.alerts.law)
Discord = BccUtils.Discord.setup(Config.webhook.link, Config.webhook.title, Config.webhook.avatar)

-- Shared state tables (accessible across all server files)
ActiveTrains = {}
LockpickAttempts = {}
CooldownData = {}
ActiveMissions = {}     -- Track active delivery missions
OperationCooldowns = {} -- Track cooldowns for expensive operations
DevModeActive = Config.devMode.active or false
TrainEntity = nil
BridgeDestroyed = false

-- Track spawned trains by region for spawn limits
SpawnedTrainsByRegion = {
    east = 0, -- outWest = false
    west = 0  -- outWest = true
}

-- Get train configuration by hex hash from all categories
function GetTrainConfig(hexHash)
    if not hexHash then
        DBG.Warning('GetTrainConfig called with nil hash')
        return nil
    end

    local config = (Cargo and Cargo[hexHash]) or
        (Passenger and Passenger[hexHash]) or
        (Mixed and Mixed[hexHash]) or
        (Special and Special[hexHash])

    if not config then
        DBG.Warning(string.format('Train configuration not found for hash: %s', tostring(hexHash)))
    end

    return config
end

-- Validate that a player owns a specific train
function ValidateTrainOwnership(source, trainId)
    if not source or not trainId then
        DBG.Error('ValidateTrainOwnership called with invalid parameters')
        return false
    end

    -- Validate trainId is a number to prevent SQL injection
    local numericTrainId = tonumber(trainId)
    if not numericTrainId or numericTrainId <= 0 then
        DBG.Error('Invalid train ID format provided')
        return false
    end

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

    -- Query database to check if player owns this train
    local result = MySQL.query.await(
        'SELECT COUNT(*) as count FROM `bcc_player_trains` WHERE `charidentifier` = ? AND `trainid` = ?',
        { character.charIdentifier, numericTrainId })

    if not result or not result[1] or result[1].count == 0 then
        DBG.Warning(string.format('Player %s (char: %s) attempted to access train %s they do not own',
            tostring(source), tostring(character.charIdentifier), tostring(numericTrainId)))
        return false
    end

    return true
end

-- Rate limiting functions
function CheckOperationCooldown(source, operation, cooldownSeconds)
    -- Check if rate limiting is disabled
    if not Config.rateLimiting or not Config.rateLimiting.enabled then
        return true, 0
    end

    if not source or not operation then
        return false
    end

    -- Get character identifier for proper cooldown tracking
    local user = Core.getUser(source)
    if not user then
        DBG.Warning(string.format('Could not get user for cooldown check: source=%s', tostring(source)))
        return false
    end

    local character = user.getUsedCharacter
    if not character then
        DBG.Warning('Could not get character for cooldown check')
        return false
    end

    local playerKey = tostring(character.charIdentifier)
    local currentTime = os.time()

    if not OperationCooldowns[playerKey] then
        OperationCooldowns[playerKey] = {}
    end

    -- Check if cooldown exists and is still active
    if OperationCooldowns[playerKey][operation] then
        local timeRemaining = OperationCooldowns[playerKey][operation] - currentTime
        if timeRemaining > 0 then
            return false, timeRemaining
        else
            -- Clean up expired cooldown
            OperationCooldowns[playerKey][operation] = nil
        end
    end

    -- Set cooldown
    OperationCooldowns[playerKey][operation] = currentTime + cooldownSeconds
    return true, 0
end

-- Periodic cleanup of expired cooldowns (runs every 5 minutes)
local function cleanupExpiredCooldowns()
    local currentTime = os.time()
    local cleanedCount = 0

    for charIdentifier, operations in pairs(OperationCooldowns) do
        for operation, expireTime in pairs(operations) do
            if expireTime <= currentTime then
                operations[operation] = nil
                cleanedCount = cleanedCount + 1
            end
        end

        -- Remove empty character entries
        if next(operations) == nil then
            OperationCooldowns[charIdentifier] = nil
        end
    end

    if cleanedCount > 0 then
        DBG.Info(string.format('Cleaned up %d expired cooldowns', cleanedCount))
    end
end

-- Start periodic cleanup timer
CreateThread(function()
    while true do
        Wait(300000) -- Wait 5 minutes
        cleanupExpiredCooldowns()
    end
end)

-- Cleanup disconnected players from tracking tables
local function cleanupDisconnectedPlayer(source)
    -- Get character identifier before user disconnects
    local user = Core.getUser(source)
    local charIdentifier = nil
    if user then
        local character = user.getUsedCharacter
        if character then
            charIdentifier = character.charIdentifier
        end
    end

    -- Clean up tracking tables
    if LockpickAttempts[source] then
        LockpickAttempts[source] = nil
    end

    -- Clean up operation cooldowns by character identifier if available
    if charIdentifier and OperationCooldowns[tostring(charIdentifier)] then
        OperationCooldowns[tostring(charIdentifier)] = nil
    end

    if ActiveMissions[source] then
        ActiveMissions[source] = nil
    end

    DBG.Info(string.format('Cleaned up tracking data for disconnected player: src=%s char=%s', 
        tostring(source), tostring(charIdentifier or 'unknown')))
end

-- Handle player disconnection
AddEventHandler('playerDropped', function(reason)
    local source = source
    cleanupDisconnectedPlayer(source)
end)

-- Server callback to get train config for a train model
Core.Callback.Register('bcc-train:server:GetTrainConfig', function(source, cb, model)
    local trainCfg = GetTrainConfig(model)
    cb(trainCfg)
end)

-- Get regional spawn counts callback
Core.Callback.Register('bcc-train:GetRegionalSpawnCounts', function(source, cb)
    cb(SpawnedTrainsByRegion)
end)

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-train')
