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

local trainSpawned = false
VORPcore.addRpcCallback("bcc-train:AllowTrainSpawn", function(source, cb)
  if trainSpawned then
    cb(false)
  else
    cb(true)
  end
end)

RegisterServerEvent('bcc-train:UpdateTrainSpawnVar', function(updateBool)
  if updateBool then
    trainSpawned = true
  else
    trainSpawned = false
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
  else
    VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
  end
end)