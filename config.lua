Config = {}

Config.defaultlang = 'en_lang'

Config.ConductorJob = 'conductor' --job title of who can spawn a train

Config.Trains = {
    {
        model = 'appleseed_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'bountyhunter_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'dummy_engine_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'engine_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'ghost_train_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'gunslinger3_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'gunslinger4_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'handcart_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'industry2_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'minecart_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'prisoner_escort_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'trolley_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    },
    {
        model = 'winter4_config',
        speedRange = {1, 10} --1 is the lowest 10 is the highest
    }
}

Config.Stations = {
    { --valentine
        coords = {x = -176.01, y = 627.86, z = 114.09},
        radius = 2, --keep this kind of low
        invLimit = 200
    }
}