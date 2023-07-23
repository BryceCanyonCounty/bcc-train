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

Config.Stations = {
    { --valentine
        coords = {x = -176.01, y = 627.86, z = 114.09},
        radius = 2, --keep this kind of low
        invLimit = 200
    },
    { --emerald station
        coords = {x = 1525.18, y = 442.51, z = 90.68},
        radius = 2,
        invLimit = 50
    },
    { --flatneck station
        coords = {x = -337.13, y = -360.63, z = 88.08},
        radius = 2,
        invLimit = 200
    },
    { --rhodes
        coords = {x = 1225.77, y = -1296.45, z = 76.9},
        radius = 2,
        invLimit = 200
    },
    { --Saint Denis
        coords = {x = 2747.5, y = -1398.89, z = 46.18},
        radius = 2,
        invLimit = 300
    },
    { --annesburge
        coords = {x = 2938.98, y = 1282.05, z = 44.65},
        radius = 2,
        invLimit = 100
    },
    { --bacchus station
        coords = {x = 582.49, y = 1681.07, z = 187.79},
        radius = 2,
        invLimit = 50
    },
    { --wallace station
        coords = {x = -1299.39, y = 402.09, z = 95.38},
        radius = 2,
        invLimit = 50
    },
    { --riggs station
        coords = {x = -1093.92, y = -576.97, z = 82.41},
        radius = 2,
        invLimit = 100
    },
    { --armadillo
        coords = {x = -3729.1, y = -2602.83, z = -12.94},
        radius = 2,
        invLimit = 300
    },
    { --Benedict Point
        coords = {x = -5230.27, y = -3468.65, z = -20.58},
        radius = 2,
        invLimit = 100
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