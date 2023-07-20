VORPcore = {}
TriggerEvent("getCore", function(core)
  VORPcore = core
end)
VORPInv = {}
VORPInv = exports.vorp_inventory:vorp_inventoryApi()

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
  else
    TrainSpawned = false
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
    Wait(1000)
    local result = MySQL.query.await("SELECT * FROM train WHERE trainModel=@trainModel", param)
    if #result > 0 then
      for k, v in pairs(Config.Trains) do
        if result[1].trainModel == v.model then
          VORPInv.removeInventory('Train_' .. result[1].trainid .. '_bcc-traininv')
          Wait(50)
          VORPInv.registerInventory('Train_' .. result[1].trainid .. '_bcc-traininv', _U("trainInv"), v.invLimit, true, true, true) break
        end
      end
    end
  else
    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
  end
end)

RegisterServerEvent('bcc-train:OpenTrainInv', function(trainId)
  local _source = source
  VORPInv.OpenInv(_source, 'Train_' .. trainId .. '_bcc-traininv')
end)