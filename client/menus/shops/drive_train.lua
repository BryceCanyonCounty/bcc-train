local Core = exports.vorp_core:GetCore()
local Menu = exports.vorp_menu:GetMenuData()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

local switched = false

-- persist the selected driving speed across menu redraws
DrivingMenuSpeed = DrivingMenuSpeed or 0
local function TrackSwitch(toggle)
    local trackModels = {
        { model = 'FREIGHT_GROUP' },
        { model = 'TRAINS3' },
        { model = 'BRAITHWAITES2_TRACK_CONFIG' },
        { model = 'TRAINS_OLD_WEST01' },
        { model = 'TRAINS_OLD_WEST03' },
        { model = 'TRAINS_NB1' },
        { model = 'TRAINS_INTERSECTION1_ANN' },
    }
    local counter = 0
    repeat
    for _, v in pairs(trackModels) do
        local trackHash = joaat(v.model)
        Citizen.InvokeNative(0xE6C5E2125EB210C1, trackHash, counter, toggle) -- SetTrainTrackJunctionSwitch
    end
    counter = counter + 1
    until counter >= 25
end

local function MaxSpeedCalc(speed)
    local setMaxSpeed = math.min(speed + 0.1, 29.9)
    Citizen.InvokeNative(0x9F29999DFDF2AEB8, MyTrain, setMaxSpeed) -- SetTrainMaxSpeed
end

-- Helper to apply a signed train speed to natives while clamping to 29.9 max
local function ApplyNativeTrainSpeed(signedTarget)
    if not MyTrain or MyTrain == 0 then return end
    local buffer = 0.1
    local mag = math.min(math.abs(signedTarget) + buffer, 29.9)
    if signedTarget >= 0 then
        Citizen.InvokeNative(0xDFBA6BBFF7CCAFBB, MyTrain, mag) -- SetTrainSpeed (positive)
        Citizen.InvokeNative(0x9F29999DFDF2AEB8, MyTrain, mag) -- SetTrainMaxSpeed
    else
        Citizen.InvokeNative(0xDFBA6BBFF7CCAFBB, MyTrain, -mag) -- SetTrainSpeed (negative)
        Citizen.InvokeNative(0x9F29999DFDF2AEB8, MyTrain, mag) -- SetTrainMaxSpeed
    end
end

-- Shared stepped ramp helper: ramps linearly from 'fromMag' to 'toMag' over
-- RAMP_STEPS steps, waiting RAMP_STEP_WAIT ms between steps. This ensures
-- engine stop and cruise on/off use identical ramp behavior and timing.
-- Read ramp settings from config, with sensible defaults
local RAMP_STEPS = (Config and Config.driving and Config.driving.rampSteps) or 16
local RAMP_STEP_WAIT = (Config and Config.driving and Config.driving.rampStepWait) or 125
local function StepRampLinear(fromMag, toMag, sign)
    local steps = RAMP_STEPS
    if steps <= 0 then
        CruiseAppliedMag = toMag
        if MyTrain and MyTrain ~= 0 then ApplyNativeTrainSpeed(sign * toMag) end
        return
    end
    for i = 1, steps do
        local t = i / steps
        local mag = fromMag + (toMag - fromMag) * t
        CruiseAppliedMag = mag
        if MyTrain and MyTrain ~= 0 then
            ApplyNativeTrainSpeed(sign * mag)
        end
        Wait(RAMP_STEP_WAIT)
    end
    CruiseAppliedMag = toMag
    if MyTrain and MyTrain ~= 0 then ApplyNativeTrainSpeed(sign * toMag) end
end

-- Smoothly ramp the train speed down to zero over several steps
local function SmoothStopTrain()
    if not MyTrain or MyTrain == 0 then
        DrivingMenuSpeed = 0
        CruiseAppliedMag = 0.0
        CruiseActive = false
        ForwardActive = false
        BackwardActive = false
        return
    end
    -- read current signed velocity
    local vel = GetEntityVelocity(MyTrain)
    local fwd = GetEntityForwardVector(MyTrain)
    local signedVel = vel.x * fwd.x + vel.y * fwd.y + vel.z * fwd.z
    local sign = 1
    if signedVel < 0 then sign = -1 end
    local startMag = math.abs(signedVel)
    if startMag < 0.01 then
        ApplyNativeTrainSpeed(0.0)
        DrivingMenuSpeed = 0
        CruiseAppliedMag = 0.0
        CruiseActive = false
        ForwardActive = false
        BackwardActive = false
        return
    end

    -- ramp down in steps (use shared stepped-ramp helper to keep behavior
    -- consistent with cruise on/off).
    StepRampLinear(startMag, 0.0, sign)
    DrivingMenuSpeed = 0
    CruiseAppliedMag = 0.0
    CruiseActive = false
    ForwardActive = false
    BackwardActive = false
end

-- Single cruise helper (on/off) with smoothing and automatic direction detection
CruiseActive = CruiseActive or false
CruiseAppliedMag = CruiseAppliedMag or 0.0 -- smoothed magnitude applied to train
CruiseDirection = CruiseDirection or 1 -- 1 = forward, -1 = backward
local function startCruise()
    if CruiseActive then return end
    CruiseActive = true
    CreateThread(function()
        -- Notify depending on travel direction
        if CruiseDirection == -1 then
            Core.NotifyRightTip(_U('backwardEnabled'), 4000)
        else
            Core.NotifyRightTip(_U('forwardEnabled'), 4000)
        end
        -- Immediately hold the captured DrivingMenuSpeed when cruise is toggled
        -- on; do not perform a ramp-up. This preserves the player's current
        -- speed exactly when they engage cruise.
        local targetMag = DrivingMenuSpeed or 0
        if targetMag > 0 and MyTrain and MyTrain ~= 0 then
            CruiseAppliedMag = targetMag
            ApplyNativeTrainSpeed((CruiseDirection or 1) * targetMag)
        end

        local smoothFactor = 0.18 -- how quickly we approach the target (kept for stability)
        while CruiseActive do
            Wait(100)
            if not MyTrain or MyTrain == 0 then
                CruiseActive = false
                break
            end
            local distance = #(GetEntityCoords(MyTrain) - vector3(517.56, 1757.27, 188.34)) -- Bacchus Bridge
            if distance <= 1000 then
                Core.NotifyRightTip(_U('cruiseDisabledInRegion'), 4000)
                CruiseActive = false
                break
            end

            -- detect current travel direction from velocity projected onto forward vector
            local vel = GetEntityVelocity(MyTrain)
            local fwd = GetEntityForwardVector(MyTrain)
            local signedVel = vel.x * fwd.x + vel.y * fwd.y + vel.z * fwd.z
            if signedVel > 0.01 then
                CruiseDirection = 1
            elseif signedVel < -0.01 then
                CruiseDirection = -1
            end

            -- target magnitude is the user-selected DrivingMenuSpeed
            local targetMag = DrivingMenuSpeed or 0
            -- smooth the applied magnitude towards target
            CruiseAppliedMag = CruiseAppliedMag + (targetMag - CruiseAppliedMag) * smoothFactor

            -- if nearly zero, ensure applied mag goes to zero to stop train
            if math.abs(CruiseAppliedMag) < 0.01 then CruiseAppliedMag = 0 end

            -- auto-stop if engine turned off
            if not EngineStarted then
                CruiseActive = false
                break
            end

            -- if target is zero and applied magnitude has decayed to zero, stop cruise
            if (targetMag == 0 or DrivingMenuSpeed == 0) and CruiseAppliedMag == 0 then
                CruiseActive = false
                break
            end

            if CruiseAppliedMag >= 0.01 then
                local signedTarget = CruiseDirection * CruiseAppliedMag
                -- set both train speed and max speed (use small buffer as before)
                local buffer = 0.1
                ApplyNativeTrainSpeed(signedTarget)
            else
                -- if target magnitude is zero then ensure train stops
                ApplyNativeTrainSpeed(0.0)
            end
        end
        -- cleanup when cruise stops
        if MyTrain and MyTrain ~= 0 then
            ApplyNativeTrainSpeed(0.0)
        end
        CruiseAppliedMag = 0.0
    end)
end

local function stopCruise()
    if not CruiseActive then
        -- if not active, ensure any residual applied mag is zeroed
        CruiseAppliedMag = 0.0
        Core.NotifyRightTip(_U('cruiseStopped'), 3000)
        return
    end
    -- instead of snapping to zero, ramp CruiseAppliedMag down smoothly to zero
    CreateThread(function()
        local startMag = CruiseAppliedMag or 0.0
        local sign = CruiseDirection or 1
        StepRampLinear(startMag, 0.0, sign)
        CruiseAppliedMag = 0.0
        CruiseActive = false
        -- ensure train stops
        if MyTrain and MyTrain ~= 0 then
            ApplyNativeTrainSpeed(0.0)
        end
        Core.NotifyRightTip(_U('cruiseStopped'), 3000)
    end)
end

function DrivingMenu(trainCfg, myTrainData, freshOpen)
    -- If there's no spawned train, ensure the driving menu is closed and state cleared
    if not MyTrain or MyTrain == 0 or not DoesEntityExist(MyTrain) then
        -- use centralized handler to ensure persisted state (DrivingMenuSpeed) is reset
        TriggerEvent('bcc-train:DrivingMenuClosed')
        return
    end
    -- reset persisted speed on a fresh open (not on redraws)
    if freshOpen == true then
        DrivingMenuSpeed = 0
    end
    Menu.CloseAll()
    local elements = {}
    local speed = DrivingMenuSpeed or 0

    if EngineStarted then
        table.insert(elements, { label = _U('stopEngine'),   value = 'stopEngine',  desc = '', itemHeight = '1.5vh' })
    else
        table.insert(elements, { label = _U('startEngine'),  value = 'startEngine', desc = '', itemHeight = '1.5vh' })
    end

    table.insert(elements, {
        label = _U('speed'),
        value = speed,
        desc = '',
        itemHeight = '1.5vh',
        type = 'slider',
        min = 0,
        max = trainCfg.maxSpeed,
        hop = 1
    })

    table.insert(elements, { label = _U('switchTrack'),  value = 'switchtrack', desc = '', itemHeight = '1.5vh' })

    if Config.cruiseControl then
        table.insert(elements, { label = _U('cruiseToggle'), value = 'cruise', desc = '', itemHeight = '1.5vh' })
    end

    if trainCfg.fuel.enabled then
        -- Single button: shows current fuel and refuels when pressed
        local fuelLabel = string.format('%s: %d/%d', _U('fuel'), tonumber(TrainFuel) or 0, tonumber(trainCfg.fuel.maxAmount) or 0)
        table.insert(elements, { label = fuelLabel, value = 'fuel', desc = '', itemHeight = '1.5vh' })
    end

    if trainCfg.condition.enabled then
        -- Single button: shows current condition and repairs when pressed
        local condLabel = string.format('%s: %d/%d', _U('condition'), tonumber(TrainCondition) or 0, tonumber(trainCfg.condition.maxAmount) or 0)
        table.insert(elements, { label = condLabel, value = 'repair', desc = '', itemHeight = '1.5vh' })
    end

    Menu.Open('default', GetCurrentResourceName(), 'vorp_menu', {
        title      = _U('drivingMenu'),
        subtext    = '',
        align      = 'top-left',
        elements   = elements,
        itemHeight = '2vh',
        lastmenu   = '',
        maxVisibleItems = 9
    },
    function(data)
        if data.current == 'backup' then
            return _G[data.trigger]()
        end
        local selectedOption = {
            ['cruise'] = function()
                if not EngineStarted then
                    Core.NotifyRightTip(_U('engineMustBeStarted'), 4000)
                    return
                end
                if TrainFuel <= 0 then
                    Core.NotifyRightTip(_U('noCruiseNoFuel'), 4000)
                    return
                end

                -- Toggle cruise on/off; detect travel direction when starting
                if not CruiseActive then
                    -- detect current signed speed of the train
                    local signedSpeed = 0.0
                    if MyTrain and MyTrain ~= 0 then
                        local vel = GetEntityVelocity(MyTrain)
                        local fwd = GetEntityForwardVector(MyTrain)
                        signedSpeed = vel.x * fwd.x + vel.y * fwd.y + vel.z * fwd.z
                    end
                    if signedSpeed > 0.01 then
                        CruiseDirection = 1
                        DrivingMenuSpeed = math.max(0, math.min(math.floor(signedSpeed * 100) / 100, trainCfg.maxSpeed or 10))
                    elseif signedSpeed < -0.01 then
                        CruiseDirection = -1
                        DrivingMenuSpeed = math.max(0, math.min(math.floor(math.abs(signedSpeed) * 100) / 100, trainCfg.maxSpeed or 10))
                    end
                    -- (previously notified player of captured cruise speed; notification removed)
                    -- set compatibility flags used elsewhere
                    ForwardActive = (CruiseDirection == 1)
                    BackwardActive = (CruiseDirection == -1)
                    startCruise()
                else
                    -- turn off cruise
                    stopCruise()
                    ForwardActive = false
                    BackwardActive = false
                    DrivingMenuSpeed = 0
                end
                -- refresh menu to update cruise label
                DrivingMenu(trainCfg, myTrainData, false)
            end,
            ['switchtrack'] = function()
                if not switched then
                    TrackSwitch(true)
                    switched = true
                    Core.NotifyRightTip(_U('switchingOn'), 4000)
                else
                    TrackSwitch(false)
                    switched = false
                    Core.NotifyRightTip(_U('switchingOn'), 4000)
                end
            end,
            ['stopEngine'] = function()
                Core.NotifyRightTip(_U('engineStopped'), 4000)
                -- smoothly ramp train to stop and reset cruise/speed state
                CreateThread(function()
                    SmoothStopTrain()
                    EngineStarted = false
                    DrivingMenu(trainCfg, myTrainData, false)
                end)
            end,
            ['fuel'] = function()
                if tonumber(TrainFuel) and tonumber(trainCfg.fuel.maxAmount) and tonumber(TrainFuel) >= tonumber(trainCfg.fuel.maxAmount) then
                    Core.NotifyRightTip(_U('noFuelNeeded'), 4000)
                    return
                end

                local fuel = Core.Callback.TriggerAwait('bcc-train:FuelTrain', TrainId, TrainFuel, trainCfg)
                if fuel ~= nil then
                    TrainFuel = fuel
                    DrivingMenu(trainCfg, myTrainData, false)
                else
                    DBG.Error('Failed to fuel train')
                end
            end,
            ['repair'] = function()
                if tonumber(TrainCondition) and tonumber(trainCfg.condition.maxAmount) and tonumber(TrainCondition) >= tonumber(trainCfg.condition.maxAmount) then
                    Core.NotifyRightTip(_U('noRepairsNeeded'), 4000)
                    return
                end

                local cond = Core.Callback.TriggerAwait('bcc-train:RepairTrain', TrainId, TrainCondition, trainCfg)
                if cond ~= nil then
                    TrainCondition = cond
                    DrivingMenu(trainCfg, myTrainData, false)
                else
                    DBG.Error('Failed to repair train')
                end
            end,
            ['startEngine'] = function()
                if TrainFuel >= 1 and TrainCondition >=1 then
                    Core.NotifyRightTip(_U('engineStarted'), 4000)
                    EngineStarted = true
                    DrivingMenu(trainCfg, myTrainData, false)
                    MaxSpeedCalc(speed)
                else
                    Core.NotifyRightTip(_U('checkTrain'), 4000)
                end
            end,
            -- fuel and condition entries use the 'fuel' and 'repair' handlers respectively
        }
        if selectedOption[data.current.value] then
            selectedOption[data.current.value]()
        else --has to be done this way to get a vector menu option
            DrivingMenuSpeed = data.current.value
            MaxSpeedCalc(DrivingMenuSpeed)
        end
    end)
end
