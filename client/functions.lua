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