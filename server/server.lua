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

TrainSpawned = false
VORPcore.addRpcCallback("bcc-train:AllowTrainSpawn", function(source, cb)
  if TrainSpawned then
    cb(false)
  else
    cb(true)
  end
end)

RegisterServerEvent('bcc-train:UpdateTrainSpawnVar', function(updateBool)
  if updateBool then
    TrainSpawned = true
    BccUtils.Discord.sendMessage(Config.WebhookLink, 'BCC Train', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', _U("trainSpawnedWeb"), _U("trainSpawnedwebMain"))
  else
    TrainSpawned = false
    BccUtils.Discord.sendMessage(Config.WebhookLink, 'BCC Train', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', _U("trainSpawnedWeb"), _U("trainNotSpawnedWeb"))
  end
end)

CreateThread(function() --Registering the inventories on server start
  local result = MySQL.query.await("SELECT * FROM train")
  for k, v in pairs(result) do
    for key, value in pairs(Config.Trains) do
      if v.trainModel == value.model then
        VORPInv.removeInventory('Train_' .. v.trainid .. '_bcc-traininv')
        Wait(50)
        VORPInv.registerInventory('Train_' .. v.trainid .. '_bcc-traininv', _U("trainInv"), value.invLimit, true, true, true) break
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
  local param = { ['charidentifier'] = Character.charIdentifier, ['trainModel'] = trainTable.model, ['fuel'] = trainTable.maxFuel, ['trainCond'] = trainTable.maxCondition }
  if Character.money >= trainTable.cost then
    exports.oxmysql:execute("INSERT INTO train (`charidentifier`,`trainModel`,`fuel`,`condition`) VALUES (@charidentifier,@trainModel,@fuel,@trainCond)", param)
    Character.removeCurrency(0, trainTable.cost)
    VORPcore.NotifyRightTip(_source, _U("trainBought"), 4000)
    BccUtils.Discord.sendMessage(Config.WebhookLink, 'BCC Train', 'https://gamespot.com/a/uploads/original/1179/11799911/3383938-duck.jpg', _U("charIdWeb") .. Character.charIdentifier, _U("boughtTrainWeb") .. trainTable.model)
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
        VORPInv.registerInventory('Train_' .. result[1].trainid .. '_bcc-traininv', _U("trainInv"), value.invLimit, true, true, true)
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

RegisterServerEvent('bcc-train:DecTrainFuel', function(trainid)
  local _source = source
  local param = { ['trainId'] = trainid, ['decamount'] = Config.FuelSettings.FuelDecreaseAmount }
  exports.oxmysql:execute('UPDATE train SET `fuel`=fuel - @decamount WHERE trainid=@trainId', param)
  Wait(500)
  local result = MySQL.query.await("SELECT * FROM train WHERE trainid=@trainId", param)
  if #result > 0 then
    TriggerClientEvent('bcc-train:CleintFuelUpdate', _source, result[1].fuel)
  end
end)

RegisterServerEvent('bcc-train:FuelTrain', function(trainId, configTable)
  local _source = source
  local itemCount = VORPInv.getItemCount(_source, Config.FuelSettings.TrainFuelItem)
  if itemCount >= Config.FuelSettings.TrainFuelItemAmount then
    VORPInv.subItem(_source, Config.FuelSettings.TrainFuelItem, Config.FuelSettings.FuelDecreaseAmount)
    local param = { ['trainId'] = trainId, ['fuel'] = configTable.maxFuel }
    exports.oxmysql:execute("UPDATE train SET `fuel`=@fuel WHERE trainid=@trainId", param)
    TriggerClientEvent('bcc-train:CleintFuelUpdate', _source, configTable.maxFuel)
    VORPcore.NotifyRightTip(_source, _U("fuelAdded"), 4000)
  else
    VORPcore.NotifyRightTip(_source, _U("noItem"), 4000)
  end
end)