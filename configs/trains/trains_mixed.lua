-----------------------------------------------------
-- Mixed Train Model Config
-----------------------------------------------------
-- NOTE: 'distance' is not currently used
Mixed = {
    ['0x005E03AD'] = {
        label = 'Mixed Train 1', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x124A1F89'] = {
        label = 'Mixed Train 2', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x25E5D8FF'] = {
        label = 'Mixed Train 3', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x35D17C43'] = {
        label = 'Mixed Train 4', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x3D72571D'] = {
        label = 'Mixed Train 5', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x41436136'] = {
        label = 'Mixed Train 6', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x487B2BE7'] = {
        label = 'Mixed Train 7', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x515E31ED'] = {
        label = 'Mixed Train 8', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x57C209C4'] = {
        label = 'Mixed Train 9', -- Label to Display in Shop Menu
        distance = 5,            -- Default: 5
        maxSpeed = 30,           -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,         -- Price in Cash
            gold = 190           -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x592A5CD0'] = {
        label = 'Mixed Train 10', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x8864D73A'] = {
        label = 'Mixed Train 11', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x998A0CBC'] = {
        label = 'Mixed Train 12', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x9CBE6FEC'] = {
        label = 'Mixed Train 13', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xA91041A2'] = {
        label = 'Mixed Train 14', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xCA19C62A'] = {
        label = 'Mixed Train 15', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xD8CF6395'] = {
        label = 'Mixed Train 16', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xD92B16AE'] = {
        label = 'Mixed Train 17', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xDC9DD041'] = {
        label = 'Mixed Train 18', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xEF9FC71D'] = {
        label = 'Mixed Train 19', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xF6AA98F4'] = {
        label = 'Mixed Train 20', -- Label to Display in Shop Menu
        distance = 5,             -- Default: 5
        maxSpeed = 30,            -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,          -- Price in Cash
            gold = 190            -- Price in Gold
        },
        blip = {                 -- blip settings for train owner only
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = true,       -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = true,   -- Set false to Disable Fuel Use
            maxAmount = 100,  -- Maximum Fuel Capacity
            itemAmount = 1,   -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 30 -- Time, in Seconds, to Decrease Fuel Level by 'itemAmount'
        },
        condition = {
            enabled = true,    -- Set false to Disable Condition Decrease
            maxAmount = 100,   -- Maximum Condition Value
            itemAmount = 1,    -- Number of Items Used per 'decreaseTime' Interval
            decreaseTime = 60, -- Time, in Seconds, to Decrease Condition Level by 'itemAmount'
        },
        inventory = {
            enabled = true, -- Set false to Disable Inventory
            limit = 500,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------
}
