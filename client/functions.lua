local Core = exports.vorp_core:GetCore()
local Menu = exports.vorp_menu:GetMenuData()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

-- Train Globals
MyTrain, TrainId = 0, 0
TrainFuel, TrainCondition = 0, 0
InMenu, InMission = false, false
EngineStarted, ForwardActive, BackwardActive = false, false, false
PreviewTrain = nil
SpawnedStation = nil

-- Client-side cache for item labels to avoid repeated server RPCs
ItemLabelCache = ItemLabelCache or {}

-- Returns a human-friendly label for an item id, using a local cache and
-- falling back to a server callback. Synchronous (uses TriggerAwait) but
-- cheap after the first lookup.
function GetItemLabelCached(itemId)
    if not itemId then return tostring(itemId) end
    if ItemLabelCache[itemId] then return ItemLabelCache[itemId] end
    local ok, label = pcall(function()
        return Core.Callback.TriggerAwait('bcc-train:GetItemLabel', itemId)
    end)
    if ok and label and label ~= '' then
        ItemLabelCache[itemId] = label
        return label
    end
    -- Fallback to raw id
    ItemLabelCache[itemId] = tostring(itemId)
    return ItemLabelCache[itemId]
end

-- Batch resolver: accepts a table/array of itemIds and returns a map itemId->label.
-- Uses the local cache and only requests missing labels from the server in one RPC.
function GetItemLabelsCached(itemIds)
    if not itemIds or type(itemIds) ~= 'table' then return {} end
    local toRequest = {}
    local result = {}
    for _, id in ipairs(itemIds) do
        if ItemLabelCache[id] then
            result[id] = ItemLabelCache[id]
        else
            table.insert(toRequest, id)
        end
    end

    if #toRequest > 0 then
        local ok, res = pcall(function()
            return Core.Callback.TriggerAwait('bcc-train:GetItemLabels', toRequest)
        end)
        if ok and res and type(res) == 'table' then
            for k, v in pairs(res) do
                ItemLabelCache[k] = v
                result[k] = v
            end
        else
            -- fallback: mark requested ids as their raw ids
            for _, id in ipairs(toRequest) do
                ItemLabelCache[id] = tostring(id)
                result[id] = tostring(id)
            end
        end
    end

    return result
end

-- Initialize random seed for better math.random usage
math.randomseed(GetGameTimer() + GetRandomIntInRange(1, 1000))

function GetTrainConfig(hash)
    if not hash then
        DBG.Warning('GetTrainConfig called with nil hash')
        return nil
    end

    local config = (Cargo and Cargo[hash]) or
                   (Passenger and Passenger[hash]) or
                   (Mixed and Mixed[hash]) or
                   (Special and Special[hash])

    if not config then
        DBG.Warning(string.format('Train configuration not found for hash: %s', tostring(hash)))
    end

    return config
end

function LoadTrainCars(trainHash, isPreview)
    if not trainHash or trainHash == 0 then
        DBG.Error('Invalid trainHash provided to LoadTrainCars')
        return false
    end

    local cars = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash) -- GetNumCarsFromTrainConfig
    if cars == 0 then
        DBG.Error(string.format('Invalid train configuration - no cars found for train hash: %s', tostring(trainHash)))
        return false
    end

    -- Only log for actual spawning, not previews (reduce spam)
    if not isPreview then
        DBG.Info(string.format('Loading %d car(s) for train hash: %s', cars, tostring(trainHash)))
    end

    for index = 0, cars - 1 do
        local model = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, index) -- GetTrainModelFromTrainConfigByCarIndex
        if model ~= 0 then
            RequestModel(model, false)
            -- Set timeout (5 seconds)
            local timeout = 5000
            local startTime = GetGameTimer()

            -- Wait for model to load
            while not HasModelLoaded(model) do
                -- Check for timeout
                if GetGameTimer() - startTime > timeout then
                    DBG.Error(string.format('Timeout while loading train car model: %s', tostring(model)))
                    return false
                end
                Wait(10)
            end
        else
            DBG.Warning(string.format('Invalid model for train car index: %d', index))
        end
    end
    return true
end

AddEventHandler('bcc-train:ResetTrain', function()
    if MyTrain ~= 0 then
        if DoesEntityExist(MyTrain) then
            DeleteEntity(MyTrain)
        end
        MyTrain = 0
    end

    if InMission then
        Core.NotifyRightTip(_U('missionFailed'), 4000) 
        InMission = false
    end

    Menu.CloseAll()
    EngineStarted = false
    ForwardActive = false
    BackwardActive = false

    if DestinationBlip then
        if DoesBlipExist(DestinationBlip) then
            RemoveBlip(DestinationBlip)
        end
        DestinationBlip = nil
    end

    if DeliveryBlip then
        if DoesBlipExist(DeliveryBlip) then
            RemoveBlip(DeliveryBlip)
        end
        DeliveryBlip = nil
    end

    TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', false, nil, TrainId, SpawnedStation, nil)
    SpawnedStation = nil -- Reset the spawned station
    -- Notify local clients to clear driving menu state (keeps DrivingMenuOpened in sync)
    TriggerEvent('bcc-train:DrivingMenuClosed')
end)

function DeletePreviewTrain()
    if PreviewTrain and DoesEntityExist(PreviewTrain) then
        DeleteEntity(PreviewTrain)
        PreviewTrain = nil
        Wait(100)
    end
end

function SpawnPreviewTrainWithDirection(hash, station, direction)
    local stationCfg = Stations[station]
    if not stationCfg then
        print('Station config not found for:', station)
        return nil
    end

    local spawnCoords = nil
    if stationCfg.train and stationCfg.train.coords then
        spawnCoords = stationCfg.train.coords
    end

    if not spawnCoords then
        print('No spawn coordinates found for station:', station)
        return nil
    end

    LoadTrainCars(hash, true) -- true = isPreview
    -- Use direction parameter (true = reverse, false = normal)
    local train = CreateMissionTrain(hash, spawnCoords.x, spawnCoords.y, spawnCoords.z, direction, false, true, false)

    SetTrainSpeed(train, 0.0)
    SetTrainCruiseSpeed(train, 0.0)

    if train and DoesEntityExist(train) then
        return train
    else
        print('Train creation failed or entity does not exist')
    end

    return nil
end
