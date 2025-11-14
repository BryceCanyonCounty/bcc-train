---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

-- Main menu prompts (made global so chunked files can access)
MenuPrompt = MenuPrompt or 0
MenuGroup = MenuGroup or GetRandomIntInRange(0, 0xffffff)
BridgePrompt = BridgePrompt or 0
BridgeGroup = BridgeGroup or GetRandomIntInRange(0, 0xffffff)
MainPromptsStarted = MainPromptsStarted or false

function StartMainPrompts()
    if MainPromptsStarted then
        DBG.Success('Main Prompts already started')
        return
    end

    if not MenuGroup then
        DBG.Error('MenuGroup not initialized')
        return
    end

    if not Config or not Config.keys or not Config.keys.station or not Config.keys.bridge then
        DBG.Error('Prompt keys are not configured properly')
        return
    end

    MenuPrompt = UiPromptRegisterBegin()
    if not MenuPrompt or MenuPrompt == 0 then
        DBG.Error('Failed to register MenuPrompt')
        return
    end
    UiPromptSetControlAction(MenuPrompt, Config.keys.station)
    UiPromptSetText(MenuPrompt, CreateVarString(10, 'LITERAL_STRING', _U('openMainMenu')))
    UiPromptSetVisible(MenuPrompt, true)
    UiPromptSetStandardMode(MenuPrompt, true)
    UiPromptSetGroup(MenuPrompt, MenuGroup, 0)
    UiPromptRegisterEnd(MenuPrompt)

    BridgePrompt = UiPromptRegisterBegin()
    if not BridgePrompt or BridgePrompt == 0 then
        DBG.Error('Failed to register BridgePrompt')
        return
    end
    UiPromptSetControlAction(BridgePrompt, Config.keys.bridge)
    UiPromptSetText(BridgePrompt, CreateVarString(10, 'LITERAL_STRING', _U('blowUpBridge')))
    UiPromptSetEnabled(BridgePrompt, true)
    UiPromptSetVisible(BridgePrompt, true)
    Citizen.InvokeNative(0x74C7D7B72ED0D3CF, BridgePrompt, 'MEDIUM_TIMED_EVENT') -- PromptSetStandardizedHoldMode
    UiPromptSetGroup(BridgePrompt, BridgeGroup, 0)
    UiPromptRegisterEnd(BridgePrompt)

    MainPromptsStarted = true
    DBG.Success('Main Prompts started successfully')
end

-- Delivery prompt globals (also used across mission chunks)
DeliveryPrompt = DeliveryPrompt or 0
DeliveryGroup = DeliveryGroup or GetRandomIntInRange(0, 0xffffff)
DeliveryPromptStarted = DeliveryPromptStarted or false

function StartDeliveryPrompt()
    if DeliveryPromptStarted then
        DBG.Success('Delivery Prompt already started')
        return
    end

    if not DeliveryGroup then
        DBG.Error('DeliveryGroup not initialized')
        return
    end

    if not Config or not Config.keys or not Config.keys.delivery then
        DBG.Error('Delivery Prompt key is not configured properly')
        return
    end

    DeliveryPrompt = UiPromptRegisterBegin()
    if not DeliveryPrompt or DeliveryPrompt == 0 then
        DBG.Error('Failed to register DeliveryPrompt')
        return
    end
    UiPromptSetControlAction(DeliveryPrompt, Config.keys.delivery)
    UiPromptSetText(DeliveryPrompt, CreateVarString(10, 'LITERAL_STRING', _U('start')))
    UiPromptSetEnabled(DeliveryPrompt, true)
    UiPromptSetVisible(DeliveryPrompt, true)
    Citizen.InvokeNative(0x74C7D7B72ED0D3CF, DeliveryPrompt, 'MEDIUM_TIMED_EVENT') -- PromptSetStandardizedHoldMode
    UiPromptSetGroup(DeliveryPrompt, DeliveryGroup, 0)
    UiPromptRegisterEnd(DeliveryPrompt)

    DeliveryPromptStarted = true
    DBG.Success('Delivery Prompt started successfully')
end
