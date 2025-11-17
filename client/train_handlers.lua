-- Train event handlers: driving logic, fuel/condition management, and gamer tags

AddEventHandler('bcc-train:TrainHandler', function(trainCfg, myTrainData)
    DrivingMenuOpened = false
    local despawnDist = Config.despawnDist or 300.0
    while MyTrain ~= 0 do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local isDead = IsEntityDead(playerPed)
        local distance = #(GetEntityCoords(playerPed) - GetEntityCoords(MyTrain))
        if distance >= despawnDist or isDead then
            if MyTrain ~= 0 then
                if distance >= despawnDist and not isDead then
                    Core.NotifyRightTip(_U('trainReturnedDistance'), 4000)
                end
                TriggerEvent('bcc-train:ResetTrain')
                break
            end
        elseif distance <= 10 then
            sleep = 0
            if not Citizen.InvokeNative(0xE052C1B1CAA4ECE4, MyTrain, -1) and GetPedInVehicleSeat(MyTrain, -1) == playerPed then -- IsVehicleSeatFree
                if not DrivingMenuOpened then
                    DrivingMenuOpened = true
                    -- Freshly opening the driving menu (player just entered seat) should reset persisted speed
                    DrivingMenu(trainCfg, myTrainData, true)
                end
            else
                if DrivingMenuOpened then
                    -- Use centralized handler so persisted state (like DrivingMenuSpeed) is reset
                    TriggerEvent('bcc-train:DrivingMenuClosed')
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('bcc-train:TrainTag', function(trainCfg, myTrainData)
    local tagDist = trainCfg.gamerTag.distance
    local tagId = Citizen.InvokeNative(0xE961BF23EAB76B12, MyTrain, myTrainData.name) -- CreateMpGamerTagOnEntity
    while MyTrain ~= 0 do
        Wait(1000)
        local playerPed = PlayerPedId()
        local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(MyTrain))

        if dist <= tagDist and not Citizen.InvokeNative(0xEC5F66E459AF3BB2, playerPed, MyTrain) then -- IsPedOnSpecificVehicle
            Citizen.InvokeNative(0x93171DDDAB274EB8, tagId, 3)                                       -- SetMpGamerTagVisibility
        else
            if Citizen.InvokeNative(0x502E1591A504F843, tagId, MyTrain) then                         -- IsMpGamerTagActiveOnEntity
                Citizen.InvokeNative(0x93171DDDAB274EB8, tagId, 0)                                   -- SetMpGamerTagVisibility
            end
        end
    end
    Citizen.InvokeNative(0x839BFD7D7E49FE09, Citizen.PointerValueIntInitialized(tagId)) -- RemoveMpGamerTag
end)

-- Ensure DrivingMenu is closed when train is reset or player is ejected
AddEventHandler('bcc-train:DrivingMenuClosed', function()
    if DrivingMenuOpened then
        DrivingMenuOpened = false
        VorpMenu.CloseAll()
        ForwardActive = false
        BackwardActive = false
    end
    -- reset persisted speed
    DrivingMenuSpeed = 0
end)

local function startPeriodicTrainStat(statName, getValueFn, setValueFn, cfgField, serverCallback, trainCfg, myTrainData)
    -- Runs in its own thread; waits the configured interval between server calls
    CreateThread(function()
        local interval = (trainCfg[cfgField].decreaseTime or 60) * 1000
        local emptyFlag = false
        while MyTrain ~= 0 do
            if EngineStarted and getValueFn() >= 1 then
                -- Wait the configured interval once (avoids extra small waits)
                Wait(interval)
                local ok, res = pcall(function()
                    return Core.Callback.TriggerAwait(serverCallback, TrainId, getValueFn(), trainCfg)
                end)
                if ok and res ~= nil then
                    setValueFn(tonumber(res))
                    if DrivingMenuOpened then
                        DrivingMenu(trainCfg, myTrainData, false)
                    end
                else
                    DBG.Error('Failed to update train ' .. statName)
                end
            else
                -- Ensure train won't move if engine isn't started or stat is depleted
                if MyTrain and MyTrain ~= 0 then
                    Citizen.InvokeNative(0x9F29999DFDF2AEB8, MyTrain, 0.0) -- SetTrainMaxSpeed
                end
                Wait(1000)
            end

            local current = getValueFn()
            if current <= 0 and not emptyFlag then
                emptyFlag = true
                EngineStarted = false
                if MyTrain and MyTrain ~= 0 then
                    Citizen.InvokeNative(0x9F29999DFDF2AEB8, MyTrain, 0.0) -- SetTrainMaxSpeed
                end
                if DrivingMenuOpened then
                    DrivingMenu(trainCfg, myTrainData, false)
                end
            elseif emptyFlag and current >= 1 then
                emptyFlag = false
            end
        end
    end)
end

AddEventHandler('bcc-train:FuelDecreaseHandler', function(trainCfg, myTrainData)
    -- get/set helpers for TrainFuel
    startPeriodicTrainStat('fuel', function() return TrainFuel end, function(v) TrainFuel = v end, 'fuel', 'bcc-train:DecTrainFuel', trainCfg, myTrainData)
end)

AddEventHandler('bcc-train:CondDecreaseHandler', function(trainCfg, myTrainData)
    -- get/set helpers for TrainCondition
    startPeriodicTrainStat('condition', function() return TrainCondition end, function(v) TrainCondition = v end, 'condition', 'bcc-train:DecTrainCond', trainCfg, myTrainData)
end)
