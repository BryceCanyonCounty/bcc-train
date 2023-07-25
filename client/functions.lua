VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)

VORPutils = {}
TriggerEvent("getUtils", function(utils)
  VORPutils = utils
end)

TriggerEvent("menuapi:getData", function(call)
  MenuData = call
end)

BccUtils = exports['bcc-utils'].initiate()
MiniGame = exports['bcc-minigames'].initiate()

function loadModel(model) --function to load a model
  RequestModel(model)
  while not HasModelLoaded(model) do
    Wait(100)
  end
end

function showHUD(condition, maxCondition, fuel, maxFuel)
  SendNUIMessage({
    type = 'toggleHUD',
    HUDvisible = true,
    condition = condition,
    maxCondition = maxCondition,
    fuel = fuel,
    maxFuel = maxFuel
  })
end

function updateHUD(condition, fuel)
  SendNUIMessage({
    type = 'update',
    condition = condition,
    fuel = fuel
  })
end

function hideHUD()
  SendNUIMessage({
    type = 'toggleHUD',
    HUDvisible = false,
  })
end

AddEventHandler('bcc-train:TrainTargetted', function()
  local player = PlayerPedId()
  local id = PlayerId()
  local returnDist = 5.5
  while DoesEntityExist(CreatedTrain) do
    local sleep = 1000
    local dist = #(GetEntityCoords(player) - GetEntityCoords(CreatedTrain))
    if dist <= returnDist then
      Citizen.InvokeNative(0x05254BA0B44ADC16, CreatedTrain, true) -- SetVehicleCanBeTargetted
      if Citizen.InvokeNative(0x6F972C1AB75A1ED0, player) then -- IsPedOnAnyTrain
        Citizen.InvokeNative(0x05254BA0B44ADC16, CreatedTrain, true) -- SetVehicleCanBeTargetted
        local _, targetEntity = GetPlayerTargetEntity(id)
        if Citizen.InvokeNative(0x27F89FDC16688A7A, id, CreatedTrain, 0) then -- IsPlayerTargettingEntity
          sleep = 0
          local wagonGroup = Citizen.InvokeNative(0xB796970BD125FCE8, targetEntity) -- PromptGetGroupIdForTargetEntity
          TriggerEvent('bcc-wagons:TargetReturn', wagonGroup)
          if Citizen.InvokeNative(0x580417101DDB492F, 2, 0x5415BE48) then -- IsControlJustPressed
            TriggerServerEvent('bcc-train:FuelTrain', TrainId, TrainConfigtable)
          elseif Citizen.InvokeNative(0x580417101DDB492F, 2, 0x73A8FD83) then
            TriggerServerEvent('bcc-train:RepairTrain', TrainId, TrainConfigtable)
          end
        end
      else
        Citizen.InvokeNative(0x05254BA0B44ADC16, CreatedTrain, false) -- SetVehicleCanBeTargetted
      end
    else
      Citizen.InvokeNative(0x05254BA0B44ADC16, CreatedTrain, false) -- SetVehicleCanBeTargetted
    end
      Wait(sleep)
  end
end)

AddEventHandler('bcc-wagons:TargetReturn', function(wagonGroup)
  local str = CreateVarString(10, 'LITERAL_STRING', _U("addFuel"))
  local targetReturn = PromptRegisterBegin()
  PromptSetControlAction(targetReturn, 0x5415BE48)
  PromptSetText(targetReturn, str)
  PromptSetEnabled(targetReturn, 1)
  PromptSetVisible(targetReturn, 1)
  PromptSetHoldMode(targetReturn, 1)
  PromptSetGroup(targetReturn, wagonGroup)
  PromptRegisterEnd(targetReturn)

  local str2 = CreateVarString(10, 'LITERAL_STRING', _U("repairdTrain"))
  local targetReturn2 = PromptRegisterBegin()
  PromptSetControlAction(targetReturn2, 0x73A8FD83)
  PromptSetText(targetReturn2, str2)
  PromptSetEnabled(targetReturn2, 1)
  PromptSetVisible(targetReturn2, 1)
  PromptSetHoldMode(targetReturn2, 1)
  PromptSetGroup(targetReturn2, wagonGroup)
  PromptRegisterEnd(targetReturn2)
end)

function loadTrainCars(trainHash)
  local trainWagons = Citizen.InvokeNative(0x635423d55ca84fc8, trainHash)
  for wagonIndex = 0, trainWagons - 1 do
    local trainWagonModel = Citizen.InvokeNative(0x8df5f6a19f99f0d5, trainHash, wagonIndex)
    while not HasModelLoaded(trainWagonModel) do
      Citizen.InvokeNative(0xFA28FE3A6246FC30, trainWagonModel, 1)
      Wait(100)
    end
  end
end

function trackSwitch(toggle)
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
    for k, v in pairs(trackModels) do
      local trackHash = joaat(v.model)
      Citizen.InvokeNative(0xE6C5E2125EB210C1, trackHash, counter, toggle)
    end
    counter = counter + 1
  until counter >= 25
end