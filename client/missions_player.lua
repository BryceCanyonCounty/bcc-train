local Core = exports.vorp_core:GetCore()
local MiniGame = exports['bcc-minigames'].initiate()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

AddEventHandler('bcc-train:PlayerDelivery', function(destination)
    StartDeliveryPrompt()
    local deliveryCoords = destination.deliveryCoords
    DeliveryBlip = Citizen.InvokeNative(0x554D9D53F696D002, -1282792512, deliveryCoords) -- BlipAddForCoords
    Citizen.InvokeNative(0x9CB1A1623062F402, DeliveryBlip, _U('deliverySpot')) -- SetBlipName

    while InMission do
        local sleep = 1000
        local distance = #(GetEntityCoords(PlayerPedId()) - deliveryCoords)
        if distance <= 2 then
            sleep = 0
            UiPromptSetActiveGroupThisFrame(DeliveryGroup, CreateVarString(10, 'LITERAL_STRING', _U('completeDelivery')), 1, 0, 0, 0)
            if Citizen.InvokeNative(0xE0F65F0640EF0617, DeliveryPrompt) then -- PromptHasHoldModeCompleted
                Wait(500)
                MiniGame.Start('skillcheck', Config.minigame, function(result)
                    if result.passed then
                        local cash = (destination.rewards and destination.rewards.cash) or 0
                        Core.NotifyRightTip(_U('deliveryDone') .. cash, 4000)
                        TriggerServerEvent('bcc-train:DeliveryPay', destination)
                        TriggerServerEvent('bcc-train:SetPlayerCooldown', 'delivery')
                    else
                        Core.NotifyRightTip(_U('missionFailed'), 4000)
                    end
                    RemoveBlip(DeliveryBlip)
                    InMission = false
                end)
                break
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('bcc-train:DeliveryHelper', function()
    while InMission do
        Wait(1000)
        if IsEntityDead(PlayerPedId()) or not MyTrain or MyTrain == 0 then
            TriggerEvent('bcc-train:ResetTrain')
            break
        end
    end
end)
