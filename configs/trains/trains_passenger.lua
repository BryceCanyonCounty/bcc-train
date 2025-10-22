-----------------------------------------------------
-- Passenger Train Model Config
-----------------------------------------------------
-- NOTE: 'distance' is not currently used
Passenger = {
    ['0x10461E19'] = {
        label = 'Passenger Train 1', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0x1C043595'] = {
        label = 'Passenger Train 2', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0x1C9936BB'] = {
        label = 'Passenger Train 3', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0x2D3645FA'] = {
        label = 'Passenger Train 4', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0x3ADC4DA9'] = {
        label = 'Passenger Train 5', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0x4A73E49C'] = {
        label = 'Passenger Train 6', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0x4C9CCB22'] = {
        label = 'Passenger Train 7', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0x98427740'] = {
        label = 'Passenger Train 8', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0xA8B1CEB7'] = {
        label = 'Passenger Train 9', -- Label to Display in Shop Menu
        distance = 5,                -- Default: 5
        maxSpeed = 30,               -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,             -- Price in Cash
            gold = 190               -- Price in Gold
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

    ['0xC732CDC8'] = {
        label = 'Passenger Train 10', -- Label to Display in Shop Menu
        distance = 5,                 -- Default: 5
        maxSpeed = 30,                -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,              -- Price in Cash
            gold = 190                -- Price in Gold
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

    ['0xCD2C7CA1'] = {
        label = 'Passenger Train 11', -- Label to Display in Shop Menu
        distance = 5,                 -- Default: 5
        maxSpeed = 30,                -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,              -- Price in Cash
            gold = 190                -- Price in Gold
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

    ['0xDD920DAF'] = {
        label = 'Passenger Train 12', -- Label to Display in Shop Menu
        distance = 5,                 -- Default: 5
        maxSpeed = 30,                -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,              -- Price in Cash
            gold = 190                -- Price in Gold
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

    ['0xE16CA3EF'] = {
        label = 'Passenger Train 13', -- Label to Display in Shop Menu
        distance = 5,                 -- Default: 5
        maxSpeed = 30,                -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,              -- Price in Cash
            gold = 190                -- Price in Gold
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

    ['0xFAB2FFB9'] = {
        label = 'Passenger Train 14', -- Label to Display in Shop Menu
        distance = 5,                 -- Default: 5
        maxSpeed = 30,                -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,              -- Price in Cash
            gold = 190                -- Price in Gold
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
