Config = {

    defaultlang = 'en_lang',
    -----------------------------------------------------

    devMode = {
        active = false, -- Set true to view debug prints
    },
    -----------------------------------------------------

    -- Rate limiting configuration
    rateLimiting = {
        enabled = true,            -- Set false to disable all rate limiting
        fuelCooldown = 30,         -- Seconds between fuel operations
        repairCooldown = 45,       -- Seconds between repair operations
        lockpickCooldown = 10,     -- Seconds between lockpick attempts
        lockpickBreakPenalty = 60, -- Additional seconds after breaking lockpick
        purchaseCooldown = 5,      -- Seconds between train purchases (prevents duplicate buys)
        renameCooldown = 10,       -- Seconds between train rename operations (prevents spam)
        sellCooldown = 5,          -- Seconds between train sell operations (prevents accidental double-sell)
    },
    -----------------------------------------------------

    autoSeedDatabase = true, -- Set true to automatically add items to database on server start
    -----------------------------------------------------

    keys = {
        station   = 0x760A9C6F, -- Default: 0x760A9C6F [G] Open Shop Menu
        ret       = 0x27D1C284, -- Default: 0x27D1C284 [R] Return Train at Shop
        bridge    = 0x760A9C6F, -- Default: 0x760A9C6F [G] Blow Up Bridge
        delivery  = 0x760A9C6F, -- Default: 0x760A9C6F [G] Start Delivery Mission Minigame
        inventory = 0xD8F73058, -- Default: 0xD8F73058 [U] Open Train Inventory
    },
    -----------------------------------------------------

    commands = {
        trainInv = 'traininv',     -- Command to open train inventory
        showTrains = 'showtrains', -- Command to show active trains on the map
    },
    -----------------------------------------------------

    webhook = {
        link = '',           -- Insert Webhook Link to Enable
        title = 'BCC-Train', -- Insert Webhook Title
        avatar = '',         -- Insert Webhook Avatar
    },
    -----------------------------------------------------

    maxTrains = 5, -- Max Number of Trains a Player may Own
    -----------------------------------------------------

    -- Train Spawn Limits per Region
    spawnLimits = {
        east = 1, -- Max number of trains that can be spawned in the East region (outWest = false)
        west = 1, -- Max number of trains that can be spawned in the West region (outWest = true)
    },
    -----------------------------------------------------

    sellPrice = 0.75, -- Default: 0.75 / Sell Price is 75% of Purchase Price
    -----------------------------------------------------

    -- Set Player in Train on Spawn from Menu
    seated = false, -- Default: false / Set to true to have Player teleport to drivers seat
    -----------------------------------------------------

    cruiseControl = false, -- Set true to Enable Cruise Control
    -----------------------------------------------------

    -- Driving / ramp settings (tweak to change speed ramp feel)
    driving = {
        rampSteps = 16,     -- Default: 16 / Number of steps used when ramping speed on/off
        rampStepWait = 125, -- Default: 125 / Milliseconds to wait between each ramp step
    },
    -----------------------------------------------------

    -- Time in Minutes Before Player can Start Delivery After Successful Completion
    cooldown = {
        delivery = 30,
    },
    -----------------------------------------------------

    -- Train Fuel and Condition Items
    fuel = {
        item = 'bagofcoal',       -- Item Name in the Database
        itemName = 'Bag of Coal', -- Item Display Name
    },

    condition = {
        item = 'trainoil',      -- Item Name in the Database
        itemName = 'Train Oil', -- Item Display Name
    },
    -----------------------------------------------------

    bacchusBridge = {
        enabled = true,                           -- Blow Up Bacchus Bridge!
        coords = vector3(492.01, 1774.41, 182.5), -- Coords of Location to Place Dynamite
        item = 'dynamite',                        -- Item Name in Database
        itemAmount = 2,                           -- Number of Items Needed
        timer = 30,                               -- Time in Seconds Before Explosion
    },
    -----------------------------------------------------

    despawnDist = 300, -- Maximum Distance Conductor can be from Train Before it Despawns
    -----------------------------------------------------

    -- Minigame Settings for Train Deliveries
    minigame = {
        focus = true,         -- Should minigame take nui focus (required)
        cursor = false,       -- Should minigame have cursor
        maxattempts = 3,      -- How many fail attempts are allowed before game over
        type = 'bar',         -- What should the bar look like. (bar, trailing)
        userandomkey = false, -- Should the minigame generate a random key to press?
        keytopress = 'B',     -- userandomkey must be false for this to work. Static key to press
        keycode = 66,         -- The JS keycode for the keytopress
        speed = 5,            -- How fast the orbiter grows
        strict = false,       -- if true, letting the timer run out counts as a failed attempt
    },
    -----------------------------------------------------

    -- Lockpick Settings
    lockpickItem = {
        'lockpick', -- Item Name in Database
        -- You can add more item names here if you want multiple items to work for lockpicking
    },

    -- Minigame Settings for Lockpicking Train Inventory
    lockPick = {
        maxAttempts = 3,      -- How many fail attempts are allowed before game over
        difficulty = 20,      -- +- threshold to the stage degree (bigger number means easier)
        hintdelay = 100,      -- milliseconds delay on when the circle will shake to show lockpick is in the right position.
        randomDegrees = true, -- If true, pins will be random degrees; if false, use static degrees
        staticDegrees = {     -- Static degrees to use when randomDegrees is false
            90,               -- Stage 1 degree (0-360)
            180,              -- Stage 2 degree (0-360)
            270,              -- Stage 3 degree (0-360)
        },
    },
    -----------------------------------------------------

    -- Alert Settings for Robbing Train Inventory (Requires bcc-job-alerts)
    alerts = {
        law = {
            name = 'bcc_train_robbery',         --The name of the alert
            command = 'trainRobbery',           -- the command, this is what players will use with /
            message = 'Train is being robbed!', -- Message to show to the police
            messageTime = 40000,                -- Time the message will stay on screen (miliseconds)
            jobs = {                            -- Job the alert is for
                'police',
                'sheriff',
            },
            jobgrade = { -- What grades the alert will effect
                police = { 0, 1, 2, 3 },
                sheriff = { 0, 1, 2, 3 },
            },
            icon = 'star',                      -- The icon the alert will use
            color = 'COLOR_GOLD',               -- The color of the icon / https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/colours
            texturedict = 'generic_textures',   --https://github.com/femga/rdr3_discoveries/tree/master/useful_info_from_rpfs/textures/menu_textures
            hash = -1282792512,                 -- The radius blip
            radius = 50.0,                      -- The size of the radius blip
            blipTime = 60000,                   -- How long the blip will stay for the job (miliseconds)
            blipDelay = 1000,                   -- Delay time before the job is notified (miliseconds)
            originText = 'Robbery alert sent!', -- Text displayed to the user who enacted the command
            originTime = 4000,                  -- The time the origintext displays (miliseconds)
        },
    },
    -----------------------------------------------------

    -- Train blip display options (controls how other players see trains on the map)
    trainBlips = {
        enabled = true,         -- Enable or disable sending train blip info to other players
        nameMode = 'player',    -- 'player' = the owner's character name / 'standard' = a single fixed label (see `standardName`)
        standardName = 'Train', -- When using 'standard', this string will be shown on the blip
        sprite = -250506368,    -- Numerical ID for the blip icon
        color = 'WHITE',        -- Key from `Config.BlipColors` (see bottom of file)

        -- Network resolution: controls when the client tries to turn a server-tracked
        -- train (network id) into a local, entity-attached blip.
        resolutionRange = 400.0,     -- Distance (meters) from the train coords where the client will try to resolve the network entity
        resolutionFallbackMs = 3000, -- Milliseconds to wait before forcing a resolution attempt even if the player is farther than `resolutionRange`

        -- Permissions and behavior for the on-demand locator command `/showtrains`.
        showTrains = {
            blipDuration = 30,   -- How long (seconds) temporary locator blips last
            jobsEnabled = false, -- Require a job check before allowing `/showtrains`
            jobs = {             -- List of jobs that may use the command / ex. { name = 'police', grade = 0 }
                { name = 'trainer', grade = 0 },
            },
            -- Temporary locator blip appearance
            tempColor = 'BRIGHT_BLUE',    -- Key from Config.BlipColors for temporary locator blip
            tempRadius = 60.0,            -- Radius (meters) for radius blip placed around train coords (0 to disable)
            tempRadiusHash = -1282792512, -- Native hash used for radius blip
        },
    },
    -----------------------------------------------------

    BlipColors = {
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
    },
    -----------------------------------------------------
}
