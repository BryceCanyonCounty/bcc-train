local Core = exports.vorp_core:GetCore()
local FeatherMenu = exports['feather-menu'].initiate()
---@type BCCTrainDebugLib
local DBG = BCCTrainDebug

TrainShopMenu = FeatherMenu:RegisterMenu('bcc-train:shop:menu', {
    top = '3%',
    left = '3%',
    ['720width'] = '400px',
    ['1080width'] = '500px',
    ['2kwidth'] = '600px',
    ['4kwidth'] = '800px',
    style = {},
    contentslot = {
        style = {
            ['height'] = '400px',
            ['min-height'] = '250px'
        }
    },
    draggable = true,
    canclose = true
}, {
    opened = function()
        InMenu = true
        DisplayRadar(false)
    end,
    closed = function()
        InMenu = false
        DestroyAllCams(true)
        DisplayRadar(true)
    end
})

function ShopMenu(station)
    local MainPage = TrainShopMenu:RegisterPage('main:page')

    if not station or not Stations[station] then
        DBG.Error('Invalid station provided to ShopMenu')
        return
    end

    local stationCfg = Stations[station]

    MainPage:RegisterElement('header', {
        value = stationCfg.shop.name,
        slot = 'header',
        style = {
            ['color'] = '#999'
        }
    })

    MainPage:RegisterElement('subheader', {
        value = 'Train Management',
        slot = 'header',
        style = {
            ['font-size'] = '0.94vw',
            ['color'] = '#CC9900'
        }
    })

    MainPage:RegisterElement('line', {
        slot = 'header',
        style = {}
    })

    local mainCategories = { -- names to language file later
        { name = 'My Trains', id = 'myTrains' },
        { name = 'Buy Train', id = 'buyTrain' },
        { name = 'Delivery Mission', id = 'deliveryMission' }
    }
    if MyTrain ~= 0 then
        table.insert(mainCategories, { name = 'Return Train', id = 'returnTrain' }) -- Changed from deleteTrain
    end

    for i, category in ipairs(mainCategories) do
        MainPage:RegisterElement('button', {
            label = category.name,
            slot = 'content',
            style = {
                ['color'] = '#E0E0E0'
            },
            id = category.id
        }, function(data)
            if data.id == 'myTrains' then
                local myTrains = Core.Callback.TriggerAwait('bcc-train:GetMyTrains')
                if #myTrains <= 0 then
                    Core.NotifyRightTip(_U('noOwnedTrains'), 4000)
                else
                    MyTrainsMenu(myTrains, station)
                end

            elseif data.id == 'buyTrain' then
                BuyTrainsMenu(station)

            elseif data.id == 'deliveryMission' then
                if not MyTrain or MyTrain == 0 then
                    Core.NotifyRightTip(_U('noTrain'), 4000)
                    return
                end

                if InMission then
                    Core.NotifyRightTip(_U('inMission'), 4000)
                    return
                end

                local onCooldown = Core.Callback.TriggerAwait('bcc-train:CheckPlayerCooldown', 'delivery')
                if onCooldown == nil then
                    Core.NotifyRightTip(_U('errorOccurred'), 4000)
                    return
                end

                if onCooldown then
                    Core.NotifyRightTip(_U('cooldown'), 4000)
                    return
                end

                -- Show delivery mission confirmation page
                DeliveryMissionConfirmation(station)

            elseif data.id == 'returnTrain' then
                -- Double-check that train still exists before returning it
                if MyTrain and MyTrain ~= 0 and DoesEntityExist(MyTrain) then
                    Core.NotifyRightTip('Train returned to depot', 4000)
                    TriggerEvent('bcc-train:ResetTrain')
                    -- Close and reopen menu to refresh the return button state
                    TrainShopMenu:Close()
                    Wait(100)
                    ShopMenu(station)
                else
                    Core.NotifyRightTip('No train to return', 4000)
                end
            end
        end)
    end

    MainPage:RegisterElement('bottomline', {
        slot = 'footer',
        style = {}
    })

    MainPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    MainPage:RegisterElement('button', {
        label = 'Close',
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        TrainShopMenu:Close()
    end)

    MainPage:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    TrainShopMenu:Open({
        startupPage = MainPage
    })
end
