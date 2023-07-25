Config = {}

Config.defaultlang = 'en_lang'

Config.WebhookLink = 'yourLink' --Insert your webhook link to enable webhooking

Config.ConductorJob = 'conductor' --job title of who can spawn a train

Config.CruiseControl = false --set true if you want to allow cruise control

Config.FuelSettings = {
    TrainFuelItem = 'bagofcoal', --db name of the item needed to fuel the train
    TrainFuelItemDisplayName = 'Bag of Coal', --display name of the item
    TrainFuelItemAmount = 5, --How many of the item it will take to fuel the train
    FuelDecreaseTime = 30000, --time in ms of how often the trains fuel goes down
    FuelDecreaseAmount = 5 --amount of fuel to decrease
}

Config.ConditionSettings = {
    TrainCondItem = 'trainoil', --db name of the item needed to repair the train
    TrainCondItemDisplayName = 'Train Oil', --display name of the item
    TrainCondItemAmount = 5, --How many of the item it will take to repair the train
    CondDecreaseTime = 30000, --time in ms of how often the trains condition goes down
    CondDecreaseAmount = 5 --amount of cond to decrease
}

Config.BacchusBridgeDestroying = {
    enabled = true, --if true you will be able to blow up bacchus bridge!
    coords = {x = 492.01, y = 1774.41, z = 182.5}, --coords of where you have to  place the dynamite
    dynamiteItem = 'dynamite', --db name of the dynamite item
    dynamiteItemAmount = 2, --amount needed to explode the bridge
    explosionTimer = 30000 --time before the explosion happens
}

Config.Trains = {
    {
        model = 'appleseed_config', --model name of the train
        cost = 30, --cost to buy the train
        maxFuel = 100, --the maximum fuel amount the train can have
        maxCondition = 100, --tha maximum condition the train can be at
        maxSpeed = 30, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    }, --You can add more trains by copy pasting this table and changing what you need (if you add more models/trains I can not garuntee they work as they have not been tested)
    {
        model = 'bountyhunter_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'engine_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'ghost_train_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this trais
    },
    {
        model = 'gunslinger3_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'gunslinger4_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'handcart_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'industry2_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'minecart_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'prisoner_escort_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'trolley_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    },
    {
        model = 'winter4_config',
        cost = 30,
        maxFuel = 100,
        maxCondition = 100,
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
        allowInventory = true, --if false train inventories will be disabled
        invLimit = 100, --inventory limit for this train
    }
}
Config.TrainDespawnDist = 200 --the maximum dist the conductor can be before the train despawns

Config.StationBlipHash = 1258184551 --set the blip hash
Config.StationBlipColor = '' -- Set the blip color here
Config.Stations = {
    { --valentine
        coords = {x = -176.01, y = 627.86, z = 114.09},
        trainSpawnCoords = {x = -163.78, y = 628.17, z = 113.52}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2, --keep this kind of low
        invLimit = 200,
        stationName = 'Valentine Station'
    },
    { --emerald station
        coords = {x = 1525.18, y = 442.51, z = 90.68},
        trainSpawnCoords = {x = 1529.67, y = 442.54, z = 90.22}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 50,
        stationName = 'Emerald Station'
    },
    { --flatneck station
        coords = {x = -337.13, y = -360.63, z = 88.08},
        trainSpawnCoords = {x = -339.0, y = -350.0, z = 87.81}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 200,
        stationName = 'Flatneck Station'
    },
    { --rhodes
        coords = {x = 1225.77, y = -1296.45, z = 76.9},
        trainSpawnCoords = {x = 1226.74, y = -1310.03, z = 76.47}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 200,
        stationName = 'Rhodes Station'
    },
    { --Saint Denis
        coords = {x = 2747.5, y = -1398.89, z = 46.18},
        trainSpawnCoords = {x = 2770.08, y = -1414.51, z = 45.98}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 300,
        stationName = 'Saint Denis Station'
    },
    { --annesburg
        coords = {x = 2938.98, y = 1282.05, z = 44.65},
        trainSpawnCoords = {x = 2957.25, y = 1281.58, z = 43.95}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 100,
        stationName = 'Annesburg Station'
    },
    { --bacchus station
        coords = {x = 582.49, y = 1681.07, z = 187.79},
        trainSpawnCoords = {x = 581.14, y = 1691.8, z = 187.6}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 50,
        stationName = 'Bacchus Station'
    },
    { --wallace station
        coords = {x = -1299.39, y = 402.09, z = 95.38},
        trainSpawnCoords = {x = -1307.62, y = 406.83, z = 94.98}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 50,
        stationName = 'Wallace Station'
    },
    { --riggs station
        coords = {x = -1093.92, y = -576.97, z = 82.41},
        trainSpawnCoords = {x = -1097.07, y = -583.71, z = 81.67}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 100,
        stationName = 'Riggs Station'
    },
    { --armadillo
        coords = {x = -3729.1, y = -2602.83, z = -12.94},
        trainSpawnCoords = {x = -3748.85, y = -2600.8, z = -13.72}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 300,
        stationName = 'Armadillo Station'
    },
    { --Benedict Point
        coords = {x = -5230.27, y = -3468.65, z = -20.58},
        trainSpawnCoords = {x = -5235.54, y = -3473.3, z = -21.25}, --Make sure the coord here is directly on top of the track you want the train to spawn on!
        radius = 2,
        invLimit = 100,
        stationName = 'Benedict Station'
    }
}

Config.SupplyDeliveryLocations = {
    {
        coords = {x = 483.34, y = 659.47, z = 117.39}, --coords you will have to go to
        pay = 20, --pay it will give
        radius = 10 --How close you have to be to the coords for it to succeed
    },
    {
        coords = {x = 1527.08, y = 444.97, z = 90.68},
        pay = 30,
        radius = 10
    } --add or remove as many as you want
}

--[[--------BLIP_COLORS----------
LIGHT_BLUE    = 'BLIP_MODIFIER_MP_COLOR_1',
DARK_RED      = 'BLIP_MODIFIER_MP_COLOR_2',
PURPLE        = 'BLIP_MODIFIER_MP_COLOR_3',
ORANGE        = 'BLIP_MODIFIER_MP_COLOR_4',
TEAL          = 'BLIP_MODIFIER_MP_COLOR_5',
LIGHT_YELLOW  = 'BLIP_MODIFIER_MP_COLOR_6',
PINK          = 'BLIP_MODIFIER_MP_COLOR_7',
GREEN         = 'BLIP_MODIFIER_MP_COLOR_8',
DARK_TEAL     = 'BLIP_MODIFIER_MP_COLOR_9',
RED           = 'BLIP_MODIFIER_MP_COLOR_10',
LIGHT_GREEN   = 'BLIP_MODIFIER_MP_COLOR_11',
TEAL2         = 'BLIP_MODIFIER_MP_COLOR_12',
BLUE          = 'BLIP_MODIFIER_MP_COLOR_13',
DARK_PUPLE    = 'BLIP_MODIFIER_MP_COLOR_14',
DARK_PINK     = 'BLIP_MODIFIER_MP_COLOR_15',
DARK_DARK_RED = 'BLIP_MODIFIER_MP_COLOR_16',
GRAY          = 'BLIP_MODIFIER_MP_COLOR_17',
PINKISH       = 'BLIP_MODIFIER_MP_COLOR_18',
YELLOW_GREEN  = 'BLIP_MODIFIER_MP_COLOR_19',
DARK_GREEN    = 'BLIP_MODIFIER_MP_COLOR_20',
BRIGHT_BLUE   = 'BLIP_MODIFIER_MP_COLOR_21',
BRIGHT_PURPLE = 'BLIP_MODIFIER_MP_COLOR_22',
YELLOW_ORANGE = 'BLIP_MODIFIER_MP_COLOR_23',
BLUE2         = 'BLIP_MODIFIER_MP_COLOR_24',
TEAL3         = 'BLIP_MODIFIER_MP_COLOR_25',
TAN           = 'BLIP_MODIFIER_MP_COLOR_26',
OFF_WHITE     = 'BLIP_MODIFIER_MP_COLOR_27',
LIGHT_YELLOW2 = 'BLIP_MODIFIER_MP_COLOR_28',
LIGHT_PINK    = 'BLIP_MODIFIER_MP_COLOR_29',
LIGHT_RED     = 'BLIP_MODIFIER_MP_COLOR_30',
LIGHT_YELLOW3 = 'BLIP_MODIFIER_MP_COLOR_31',
WHITE         = 'BLIP_MODIFIER_MP_COLOR_32'
]]