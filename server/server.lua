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
  local _source = source
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