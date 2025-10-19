-----------------------------------------------------
-- Special Train Model Config
-----------------------------------------------------
-- NOTE: 'distance' is not currently used
Special = {
    ['0x0E62D710'] = {
        label = 'Ghost Train', -- Label to Display in Shop Menu
        distance = 5,          -- Default: 5
        maxSpeed = 30,         -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,       -- Price in Cash
            gold = 190         -- Price in Gold
        },
        blip = {
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

    ['0x3260CE89'] = {
        label = 'Engine Only', -- Label to Display in Shop Menu
        distance = 5,          -- Default: 5
        maxSpeed = 30,         -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 3950,       -- Price in Cash
            gold = 190         -- Price in Gold
        },
        blip = {
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

    ['0x09B679D6'] = {
        label = 'Trolley 1', -- Label to Display in Shop Menu
        distance = 5,        -- Default: 5
        maxSpeed = 15,       -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 1950,     -- Price in Cash
            gold = 95        -- Price in Gold
        },
        blip = {
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = false,      -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = false,  -- Set false to Disable Fuel Use
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
            limit = 100,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x73722125'] = {
        label = 'Trolley 2', -- Label to Display in Shop Menu
        distance = 5,        -- Default: 5
        maxSpeed = 15,       -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 1950,     -- Price in Cash
            gold = 95        -- Price in Gold
        },
        blip = {
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = false,      -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = false,  -- Set false to Disable Fuel Use
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
            limit = 100,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x90CB53CA'] = {
        label = 'Trolley 3', -- Label to Display in Shop Menu
        distance = 5,        -- Default: 5
        maxSpeed = 15,       -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 1950,     -- Price in Cash
            gold = 95        -- Price in Gold
        },
        blip = {
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = false,      -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = false,  -- Set false to Disable Fuel Use
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
            limit = 100,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0x9E096E46'] = {
        label = 'Trolley 4', -- Label to Display in Shop Menu
        distance = 5,        -- Default: 5
        maxSpeed = 15,       -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 1950,     -- Price in Cash
            gold = 95        -- Price in Gold
        },
        blip = {
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = false,      -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = false,  -- Set false to Disable Fuel Use
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
            limit = 100,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xAEE0ECF5'] = {
        label = 'Trolley 5', -- Label to Display in Shop Menu
        distance = 5,        -- Default: 5
        maxSpeed = 15,       -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 1950,     -- Price in Cash
            gold = 95        -- Price in Gold
        },
        blip = {
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = false,      -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = false,  -- Set false to Disable Fuel Use
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
            limit = 100,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xBF69518F'] = {
        label = 'Trolley 6', -- Label to Display in Shop Menu
        distance = 5,        -- Default: 5
        maxSpeed = 15,       -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 1950,     -- Price in Cash
            gold = 95        -- Price in Gold
        },
        blip = {
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = false,      -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = false,  -- Set false to Disable Fuel Use
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
            limit = 100,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------

    ['0xEFBFBDD8'] = {
        label = 'Trolley 7', -- Label to Display in Shop Menu
        distance = 5,        -- Default: 5
        maxSpeed = 15,       -- Max Speed / *30 is Highest Game Allows*
        price = {
            cash = 1950,     -- Price in Cash
            gold = 95        -- Price in Gold
        },
        blip = {
            show   = true,       -- Show Blip for Train Location
            name   = 'Train',    -- Name of Blip on the Map
            sprite = -250506368, -- Default: -250506368
            color  = 'WHITE'     -- Color of Blip
        },
        gamerTag = {
            enabled = true,   -- Default: true / Places Train Name Above Train When Empty
            distance = 15     -- Default: 15 / Distance from Train to Show Tag
        },
        steamer = false,      -- Set true if Train is Steam Powered
        fuel = {              -- Only works with Steam Powered Train
            enabled = false,  -- Set false to Disable Fuel Use
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
            limit = 100,    -- Maximum Inventory Limit
            weapons = true, -- Set false to Disable Weapons
            shared = false  -- Set true to Enable Shared Inventory
        },
        -- Only Players with Specified Job will See that Train to Purchase in the Menu
        job = {} -- Example: {'police', 'doctor'}
    },
    -----------------------------------------------------
}
