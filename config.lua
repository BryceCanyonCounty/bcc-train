Config = {}

Config.defaultlang = 'en_lang'

Config.ConductorJob = 'conductor' --job title of who can spawn a train

Config.CruiseControl = false --set true if you want to allow cruise control

Config.TrainFuelItem = 'bagofcoal' --The item needed to fuel your train
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
    }
}