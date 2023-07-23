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
