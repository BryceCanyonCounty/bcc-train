-----------------------------------------------------
-- Cargo Train Model Config
-----------------------------------------------------
-- NOTE: 'distance' is not currently used
Cargo = {
    ['0x0392C83A'] = {
        label = 'Cargo Train 1', -- Label to Display in Shop Menu
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

    ['0x0660E567'] = {
        label = 'Cargo Train 2', -- Label to Display in Shop Menu
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

    ['0x0941ADB7'] = {
        label = 'Cargo Train 3', -- Label to Display in Shop Menu
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

    ['0x0CCC2F70'] = {
        label = 'Cargo Train 4', -- Label to Display in Shop Menu
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

    ['0x0D03C58D'] = {
        label = 'Cargo Train 5', -- Label to Display in Shop Menu
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

    ['0x19A0A288'] = {
        label = 'Cargo Train 6', -- Label to Display in Shop Menu
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

    ['0x1EEC5C2A'] = {
        label = 'Cargo Train 7', -- Label to Display in Shop Menu
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

    ['0x1EF82A51'] = {
        label = 'Cargo Train 8', -- Label to Display in Shop Menu
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

    ['0x2D1A6F0C'] = {
        label = 'Cargo Train 9', -- Label to Display in Shop Menu
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

    ['0x31656D23'] = {
        label = 'Cargo Train 10', -- Label to Display in Shop Menu
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

    ['0x5AA369CA'] = {
        label = 'Cargo Train 11', -- Label to Display in Shop Menu
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

    ['0x5D9928A4'] = {
        label = 'Cargo Train 12', -- Label to Display in Shop Menu
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

    ['0x68CF495F'] = {
        label = 'Cargo Train 13', -- Label to Display in Shop Menu
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

    ['0x6CC26E27'] = {
        label = 'Cargo Train 14', -- Label to Display in Shop Menu
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

    ['0x6D69A954'] = {
        label = 'Cargo Train 15', -- Label to Display in Shop Menu
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

    ['0x761CE0AD'] = {
        label = 'Cargo Train 16', -- Label to Display in Shop Menu
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

    ['0x7BD58C4D'] = {
        label = 'Cargo Train 17', -- Label to Display in Shop Menu
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

    ['0x8D0766BC'] = {
        label = 'Cargo Train 18', -- Label to Display in Shop Menu
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

    ['0x8EAC625C'] = {
        label = 'Cargo Train 19', -- Label to Display in Shop Menu
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

    ['0x9296570E'] = {
        label = 'Cargo Train 20', -- Label to Display in Shop Menu
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

    ['0x9897FF51'] = {
        label = 'Cargo Train 21', -- Label to Display in Shop Menu
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

    ['0xA3BF0BEB'] = {
        label = 'Cargo Train 22', -- Label to Display in Shop Menu
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

    ['0xAA3E691E'] = {
        label = 'Cargo Train 23', -- Label to Display in Shop Menu
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

    ['0xAC18A9F4'] = {
        label = 'Cargo Train 24', -- Label to Display in Shop Menu
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

    ['0xAE47CA77'] = {
        label = 'Cargo Train 25', -- Label to Display in Shop Menu
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

    ['0xB1F69614'] = {
        label = 'Cargo Train 26', -- Label to Display in Shop Menu
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

    ['0xC1F1DD80'] = {
        label = 'Cargo Train 27', -- Label to Display in Shop Menu
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

    ['0xD233B18D'] = {
        label = 'Cargo Train 28', -- Label to Display in Shop Menu
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

    ['0xD42DD3EE'] = {
        label = 'Cargo Train 29', -- Label to Display in Shop Menu
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

    ['0xD5DF2D82'] = {
        label = 'Cargo Train 30', -- Label to Display in Shop Menu
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

    ['0xD93C36C2'] = {
        label = 'Cargo Train 31', -- Label to Display in Shop Menu
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

    ['0xDA2EDE2F'] = {
        label = 'Cargo Train 32', -- Label to Display in Shop Menu
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

    ['0xE0898B89'] = {
        label = 'Cargo Train 33', -- Label to Display in Shop Menu
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

    ['0xEB8B2439'] = {
        label = 'Cargo Train 34', -- Label to Display in Shop Menu
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

    ['0xF19E48CA'] = {
        label = 'Cargo Train 35', -- Label to Display in Shop Menu
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

    ['0xF9B038FC'] = {
        label = 'Cargo Train 36', -- Label to Display in Shop Menu
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

    ['0xFAC328F0'] = {
        label = 'Cargo Train 37', -- Label to Display in Shop Menu
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

    ['0xFD8810E8'] = {
        label = 'Cargo Train 38', -- Label to Display in Shop Menu
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
