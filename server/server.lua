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

RegisterServerEvent('bcc-train:InsertCharIntoDB', function()
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  local param = { ['charidentifier'] = Character.charIdentifier }
  local result = MySQL.query.await("SELECT * FROM train WHERE charidentifier=@charidentifier", param)
  if #result == 0 then
    exports.oxmysql:execute("INSERT INTO train (`charidentifier`) VALUES (@charidentifier)", param)
  end
end)

RegisterServerEvent('bcc-train:GetOwnedTrains', function(type)
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  local param = { ['charidentifier'] = Character.charIdentifier }
  local result = MySQL.query.await("SELECT * FROM train WHERE charidentifier=@charidentifier", param)
  if type == 'viewOwned' then
    if #result > 0 then
      TriggerClientEvent('bcc-train:OwnedTrainsMenu', _source, result[1])
    else
      print('no db entry for char')
    end
  elseif type == 'buyTrain' then
    if #result > 0 then
      TriggerClientEvent('bcc-train:BuyTrainMenu', _source, result[1])
    else
      print('no db entry for char')
    end
  end
end)

RegisterServerEvent('bcc-train:BoughtTrainHandler', function(trainTable)
  local _source = source
  local Character = VORPcore.getUser(_source).getUsedCharacter
  local selectionParam = { ['charidentifier'] = Character.charIdentifier }
  local result = MySQL.query.await("SELECT * FROM train WHERE charidentifier=@charidentifier", selectionParam)
  if #result > 0 then
    if Character.money >= trainTable.cost then
      local ownedTrainsTable = json.decode(result[1].ownedTrains)
      table.insert(ownedTrainsTable, { model = trainTable.model, fuel = trainTable.maxFuel, condition = trainTable.maxCondition })
      local insertionParam = { ['charidentifier'] = Character.charIdentifier, ['ownedTrains'] = json.encode(ownedTrainsTable) }
      exports.oxmysql:execute("UPDATE train SET ownedTrains=@ownedTrains WHERE charidentifier=@charidentifier", insertionParam)
      Character.removeCurrency(0, trainTable.cost)
      VORPcore.NotifyRightTip(_source, _U("trainBought"), 4000)
    else
      VORPcore.NotifyRightTip(_source, _U("notEnoughMoney"), 4000)
    end
  else
    print("no db entry for char")
  end
end)