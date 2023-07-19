Config = {}

Config.defaultlang = 'en_lang'

Config.ConductorJob = 'conductor' --job title of who can spawn a train

Config.CruiseControl = false --set true if you want to allow cruise control

Config.Trains = {
    {
        model = 'appleseed_config',
        maxSpeed = 30, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'bountyhunter_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'engine_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'ghost_train_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'gunslinger3_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'gunslinger4_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'handcart_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'industry2_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'minecart_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'prisoner_escort_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'trolley_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
    },
    {
        model = 'winter4_config',
        maxSpeed = 10, --max speed the train can go 30 is highest game allows
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