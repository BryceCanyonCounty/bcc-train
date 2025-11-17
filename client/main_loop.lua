-- Main game loop: station proximity checks, NPC management, and shop menu interaction
CreateThread(function()
    StartMainPrompts()
    SetRandomTrains(false)
    TriggerServerEvent('bcc-train:BridgeFallHandler', true)
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

        if InMenu or IsEntityDead(playerPed) then
            goto END
        end

        for station, stationCfg in pairs(Stations) do
            local distance = #(playerCoords - stationCfg.npc.coords)
            IsShopClosed = IsTrainShopClosed(stationCfg)

            ManageBlip(station, IsShopClosed)

            if distance > stationCfg.npc.distance or IsShopClosed then
                RemoveNPC(station)
            elseif stationCfg.npc.active then
                AddNPC(station)
            end

            if distance <= stationCfg.shop.distance then
                sleep = 0
                local promptText
                if IsShopClosed then
                    promptText = ('%s %s %d %s %d %s'):format(
                        stationCfg.shop.name,
                        _U('hours'),
                        stationCfg.shop.hours.open,
                        _U('to'),
                        stationCfg.shop.hours.close,
                        _U('hundred')
                    )
                else
                    promptText = stationCfg.shop.prompt
                end

                UiPromptSetActiveGroupThisFrame(MenuGroup, CreateVarString(10, 'LITERAL_STRING', promptText), 1, 0, 0, 0)
                UiPromptSetEnabled(MenuPrompt, not IsShopClosed)
                if MyTrain and MyTrain ~= 0 then
                    UiPromptSetVisible(ReturnPrompt, true)
                else
                    UiPromptSetVisible(ReturnPrompt, false)
                end

                -- Open shop menu
                if not IsShopClosed then
                    if Citizen.InvokeNative(0xE0F65F0640EF0617, MenuPrompt) then -- PromptHasHoldModeCompleted
                        Wait(500)
                        if stationCfg.shop.jobsEnabled then
                            local hasJob = Core.Callback.TriggerAwait('bcc-train:CheckJob', station)
                            if hasJob ~= true then
                                goto END
                            end
                        end
                        OpenShopMenu(station)
                    end
                end

                -- Return train at shop
                if Citizen.InvokeNative(0xE0F65F0640EF0617, ReturnPrompt) then -- PromptHasHoldModeCompleted
                    Wait(500)
                    if MyTrain and MyTrain ~= 0 and DoesEntityExist(MyTrain) then
                        Core.NotifyRightTip(_U('trainReturned'), 4000)
                        TriggerEvent('bcc-train:ResetTrain')
                    else
                        Core.NotifyRightTip(_U('noTrainToReturn'), 4000)
                    end
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

function OpenShopMenu(station)
    -- Validate station parameter
    if not station then
        DBG.Error('Invalid station provided to OpenShopMenu')
        return
    end

    -- Get station configuration
    local stationCfg = Stations[station]
    if not stationCfg or not stationCfg.train or not stationCfg.train.camera or not stationCfg.train.coords then
        DBG.Error('Invalid station configuration for camera setup in OpenShopMenu')
        return
    end

    -- Create and set up camera
    local trainCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(trainCam, stationCfg.train.camera.x, stationCfg.train.camera.y, stationCfg.train.camera.z)
    SetCamActive(trainCam, true)
    PointCamAtCoord(trainCam, stationCfg.train.coords.x, stationCfg.train.coords.y, stationCfg.train.coords.z)
    SetCamFov(trainCam, 50.0)

    -- Transition to camera and open menu
    DoScreenFadeOut(500)
    Wait(500)
    ShopMenu(station)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, false, false, 0)
end
