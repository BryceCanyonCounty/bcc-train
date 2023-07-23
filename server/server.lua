VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()
BccUtils = exports['bcc-utils'].initiate()

RegisterServerEvent('bcc-train:JobCheck', function()
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  if Character.job == Config.ConductorJob then
    TriggerClientEvent('bcc-train:MainStationMenu', _source)
  else
    VORPcore.NotifyRightTip(_source, _U("wrongJob"), 4000)
  end
end)

TrainSpawned, TrainEntity = false, nil
VORPcore.addRpcCallback("bcc-train:AllowTrainSpawn", function(source, cb)
  if TrainSpawned then
    cb(false)
  else
    cb(true)
  end
end)

RegisterServerEvent('bcc-train:UpdateTrainSpawnVar', function(updateBool, createdTrain)
  if updateBool then
    TrainSpawned = true
    TrainEntity = createdTrain
    BccUtils.Discord.sendMessage(Config.WebhookLink, 'BCC Train',
      'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', _U("trainSpawnedWeb"),
      _U("trainSpawnedwebMain"))
  else
    TrainSpawned = false
    TrainEntity = nil
    BccUtils.Discord.sendMessage(Config.WebhookLink, 'BCC Train',
      'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', _U("trainSpawnedWeb"),
      _U("trainNotSpawnedWeb"))
  end
end)

CreateThread(function() --Registering the inventories on server start
  local result = MySQL.query.await("SELECT * FROM train")
  for k, v in pairs(result) do
    for key, value in pairs(Config.Trains) do
      if v.trainModel == value.model then
        VORPInv.removeInventory('Train_' .. v.trainid .. '_bcc-traininv')
        Wait(50)
        VORPInv.registerInventory('Train_' .. v.trainid .. '_bcc-traininv', _U("trainInv"), value.invLimit, true, true,
          true)
        break
      end
    end
  end
end)

RegisterServerEvent('bcc-train:GetOwnedTrains', function(type)
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  local param = { ['charidentifier'] = Character.charIdentifier }
  local result = MySQL.query.await("SELECT * FROM train WHERE charidentifier=@charidentifier", param)
  if type == 'viewOwned' then
    TriggerClientEvent('bcc-train:OwnedTrainsMenu', _source, result)
  elseif type == 'buyTrain' then
    TriggerClientEvent('bcc-train:BuyTrainMenu', _source, result)
  end
end)

RegisterServerEvent('bcc-train:BoughtTrainHandler', function(trainTable)
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  local param = {
    ['charidentifier'] = Character.charIdentifier,
    ['trainModel'] = trainTable.model,
    ['fuel'] = trainTable.maxFuel,
    ['trainCond'] = trainTable.maxCondition
  }
  if Character.money >= trainTable.cost then
    MySQL.query.await(
      "INSERT INTO train (`charidentifier`,`trainModel`,`fuel`,`condition`) VALUES (@charidentifier,@trainModel,@fuel,@trainCond)",
      param)
    Character.removeCurrency(0, trainTable.cost)
    VORPcore.NotifyRightTip(_source, _U("trainBought"), 4000)
    BccUtils.Discord.sendMessage(Config.WebhookLink, 'BCC Train',
      'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg',
      _U("charIdWeb") .. Character.charIdentifier, _U("boughtTrainWeb") .. trainTable.model)
  else
    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
  end
end)

RegisterServerEvent('bcc-train:OpenTrainInv', function(trainId)
  local _source = source
  local param = { ['trainId'] = trainId }
  local result = MySQL.query.await("SELECT * FROM train WHERE trainid=@trainId", param)
  if #result > 0 then
    for key, value in pairs(Config.Trains) do
      if result[1].trainModel == value.model then
        VORPInv.removeInventory('Train_' .. result[1].trainid .. '_bcc-traininv')
        Wait(50)
        VORPInv.registerInventory('Train_' .. result[1].trainid .. '_bcc-traininv', _U("trainInv"), value.invLimit, true,
          true, true)
        Wait(50)
        VORPInv.OpenInv(_source, 'Train_' .. trainId .. '_bcc-traininv')
      end
    end
  end
end)

RegisterServerEvent('bcc-train:CheckTrainFuel', function(trainid, configTable)
  local _source = source
  local param = { ['trainId'] = trainid }
  local result = MySQL.query.await("SELECT * FROM train WHERE trainid=@trainId", param)
  if #result > 0 then
    VORPcore.NotifyRightTip(_source, result[1].fuel .. ' / ' .. configTable.maxFuel)
  end
end)

RegisterServerEvent('bcc-train:CheckTrainCond', function(trainid, configTable)
  local _source = source
  local param = { ['trainId'] = trainid }
  local result = MySQL.query.await("SELECT * FROM train WHERE trainid=@trainId", param)
  if #result > 0 then
    VORPcore.NotifyRightTip(_source, result[1].condition .. ' / ' .. configTable.maxCondition)
  end
end)

RegisterServerEvent('bcc-train:DecTrainFuel', function(trainid, trainFuel)
  local _source = source
  local param = { ['trainId'] = trainid, ['fuel'] = trainFuel - Config.FuelSettings.FuelDecreaseAmount }
  MySQL.query.await('UPDATE train SET fuel=@fuel WHERE trainid=@trainId', param)
  local result = MySQL.query.await("SELECT * FROM train WHERE trainid=@trainId", param)
  if #result > 0 then
    TriggerClientEvent('bcc-train:CleintFuelUpdate', _source, result[1].fuel)
  end
end)

RegisterServerEvent('bcc-train:DecTrainCond', function(trainid, trainCondition)
  local _source = source
  local param = { ['trainId'] = trainid, ['cond'] = trainCondition - Config.ConditionSettings.CondDecreaseAmount }
  MySQL.query.await('UPDATE train SET `condition`=@cond WHERE trainid=@trainId', param)
  local result = MySQL.query.await("SELECT * FROM train WHERE trainid=@trainId", param)
  if #result > 0 then
    TriggerClientEvent('bcc-train:CleintCondUpdate', _source, result[1].condition)
  end
end)

RegisterServerEvent('bcc-train:FuelTrain', function(trainId, configTable)
  local _source = source
  local itemCount = VORPInv.getItemCount(_source, Config.FuelSettings.TrainFuelItem)
  if itemCount >= Config.FuelSettings.TrainFuelItemAmount then
    VORPInv.subItem(_source, Config.FuelSettings.TrainFuelItem, Config.FuelSettings.FuelDecreaseAmount)
    local param = { ['trainId'] = trainId, ['fuel'] = configTable.maxFuel }
    MySQL.query.await("UPDATE train SET `fuel`=@fuel WHERE trainid=@trainId", param)
    TriggerClientEvent('bcc-train:CleintFuelUpdate', _source, configTable.maxFuel)
    VORPcore.NotifyRightTip(_source, _U("fuelAdded"), 4000)
  else
    VORPcore.NotifyRightTip(_source, _U("noItem"), 4000)
  end
end)

RegisterServerEvent('bcc-train:RepairTrain', function(trainId, configTable)
  local _source = source
  local itemCount = VORPInv.getItemCount(_source, Config.ConditionSettings.TrainCondItem)
  if itemCount >= Config.ConditionSettings.TrainCondItemAmount then
    VORPInv.subItem(_source, Config.ConditionSettings.TrainCondItem, Config.ConditionSettings.TrainCondItemAmount)
    local param = { ['trainId'] = trainId, ['cond'] = configTable.maxCondition }
    MySQL.query.await("UPDATE train SET `condition`=@cond WHERE trainid=@trainId", param)
    TriggerClientEvent('bcc-train:CleintCondUpdate', _source, configTable.maxCondition)
    VORPcore.NotifyRightTip(_source, _U("trainRepaired"), 4000)
  else
    VORPcore.NotifyRightTip(_source, _U("noItem"), 4000)
  end
end)

------ Baccus bridge fall area ---------
BridgeDestroyed = false
RegisterServerEvent('bcc-train:ServerBridgeFallHandler', function(freshJoin)
  local _source = source
  if not freshJoin then
    local itemCount = VORPInv.getItemCount(_source, Config.BacchusBridgeDestroying.dynamiteItem)
    if itemCount >= Config.BacchusBridgeDestroying.dynamiteItemAmount then
      if not BridgeDestroyed then
        VORPInv.subItem(_source, Config.BacchusBridgeDestroying.dynamiteItem,
          Config.BacchusBridgeDestroying.dynamiteItemAmount)
        BridgeDestroyed = true
        VORPcore.NotifyRightTip(_source, _U("runFromExplosion"), 4000)
        Wait(Config.BacchusBridgeDestroying.explosionTimer)
        TriggerClientEvent('bcc-train:BridgeFall', -1) --triggers for all cleints
      end
    else
      VORPcore.NotifyRightTip(_source, _U("noItem"), 4000)
    end
  else
    if BridgeDestroyed then
      TriggerClientEvent('bcc-train:BridgeFall', _source) --triggers for loaded in client
    end
  end
end)

RegisterServerEvent('bcc-train:DeliveryPay', function(pay)
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  Character.addCurrency(0, pay)
end)

--- Check if properly downloaded
function file_exists(name)
  local f = LoadResourceFile(GetCurrentResourceName(), name)
  return f ~= nil
end

if not file_exists('./ui/index.html') then
  print("^1 INCORRECT DOWNLOAD!  ^0")
  print(
    '^4 Please Download: ^2(bcc-stables.zip) ^4from ^3<https://github.com/BryceCanyonCounty/bcc-stables/releases/latest>^0')
end
