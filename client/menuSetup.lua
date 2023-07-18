----- Close Menu When Backspaced Out -----
local inMenu = false

AddEventHandler('bcc-train:MenuClose', function()
    while inMenu do
        Wait(5)
        if IsControlJustReleased(0, 0x156F7119) then
            inMenu = false
            MenuData.CloseAll() break
        end
    end
end)

RegisterNetEvent('bcc-train:MainStationMenu', function()
    inMenu = true
    TriggerEvent('bcc-train:MenuClose')
    MenuData.CloseAll()

    local elements = {
        { label = _U("spawnTrain"),         value = 'spawntrain',    desc = _U("spawnTrain_desc") }
    }

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("trainStation"),
            align = 'top-left',
            elements = elements,
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            local selectedOption = {
                ['spawntrain'] = function()
                    VORPcore.RpcCall("bcc-train:AllowTrainSpawn", function(result)
                        if result then
                            chooseTrainMenu()
                        else
                           VORPcore.NotifyRightTip(_U("trainSpawnedAlrady"), 4000)
                        end
                    end)
                end
            }

            if selectedOption[data.current.value] then
                selectedOption[data.current.value]()
            end
        end)
end)

function chooseTrainMenu()
    MenuData.CloseAll()
    local elements = {}

    for k, trainInfo in pairs(Config.Trains) do
        elements[#elements + 1] = {
            label = _U("trainModel") .. ' ' .. trainInfo.model,
            value = "train" .. k,
            desc = "",
            info = trainInfo
        }
    end

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title      = _U("trainMenu"),
            subtext    = _U("trainMenu_desc"),
            align      = 'top-left',
            elements   = elements,
            itemHeight = "4vh"
        },
        function(data)
            if data.current == 'backup' then
                _G[data.trigger]()
            end
            if data.current.value then
                MenuData.CloseAll()
                VORPcore.NotifyRightTip(_U("trainSpawned"), 4000)
                spawnTrain(data.current.info)
                TriggerServerEvent('bcc-train:UpdateTrainSpawnVar', true)
            end
        end)
end

function drivingTrainMenu(trainConfigTable)
    --
end