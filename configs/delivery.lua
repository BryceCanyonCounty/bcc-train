DeliveryLocations = {
    -- Heartland Oil Fields
    heartlandOil = {                                      -- Unique Key for Location
        name = 'Heartland Oil Fields',                    -- Name of Location
        trainCoords = vector3(482.21, 655.46, 115.67),    -- Stop Train for Delivery
        deliveryCoords = vector3(469.27, 669.22, 117.39), -- Player Delivery Coords
        requireItem = false,                              -- Require Item to Start Mission
        items = {                                         -- Items Required to Start Mission (ALL items listed are required to start)
            { item = 'apple', label = 'Apple', quantity = 1 },
        },
        rewards = {                        -- Rewards for Completing Mission (min/max values for random amounts)
            cash = { min = 20, max = 50 }, -- Random cash amount between min and max
            gold = { min = 1, max = 5 },   -- Random gold amount between min and max
            items = {                      -- Random quantities between min and max for each item
                { item = 'apple',   label = 'Apple',  min = 1, max = 5 },
                { item = 'carrots', label = 'Carrot', min = 1, max = 3 },
            }
        },
        outWest = false, -- Set false if This is Not in the Desert/Western Part of the Map
        radius = 10,     -- Radius from trainCoords to Stop the Train
        enabled = true   -- Set false to disable this location
    },
    -----------------------------------------------------

    -- East Hanover
    eastHanover = {                                      -- Unique Key for Location
        name = 'East Hanover',                           -- Name of Location
        trainCoords = vector3(2231.4, 657.21, 93.83),    -- Stop Train for Delivery
        deliveryCoords = vector3(2226.6, 644.73, 93.33), -- Player Delivery Coords
        requireItem = false,                             -- Require Item to Start Mission
        items = {                                        -- Items Required to Start Mission (ALL items listed are required to start)
            { item = 'apple', label = 'Apple', quantity = 1 },
        },
        rewards = {                        -- Rewards for Completing Mission (min/max values for random amounts)
            cash = { min = 20, max = 50 }, -- Random cash amount between min and max
            gold = { min = 1, max = 5 },   -- Random gold amount between min and max
            items = {                      -- Random quantities between min and max for each item
                { item = 'apple',   label = 'Apple',  min = 1, max = 5 },
                { item = 'carrots', label = 'Carrot', min = 1, max = 3 },
            }
        },
        outWest = false, -- Set false if This is Not in the Desert/Western Part of the Map
        radius = 10,     -- Radius from trainCoords to Stop the Train
        enabled = true   -- Set false to disable this location
    },
    -----------------------------------------------------

    -- St. Denis
    stDenis = {                                             -- Unique Key for Location
        name = 'St. Denis Station',                         -- Name of Location
        trainCoords = vector3(2712.19, -1467.63, 45.75),    -- Stop Train for Delivery
        deliveryCoords = vector3(2713.09, -1491.56, 45.97), -- Player Delivery Coords
        requireItem = false,                                -- Require Item to Start Mission
        items = {                                           -- Items Required to Start Mission (ALL items listed are required to start)
            { item = 'apple', label = 'Apple', quantity = 1 },
        },
        rewards = {                        -- Rewards for Completing Mission (min/max values for random amounts)
            cash = { min = 20, max = 50 }, -- Random cash amount between min and max
            gold = { min = 1, max = 5 },   -- Random gold amount between min and max
            items = {                      -- Random quantities between min and max for each item
                { item = 'apple',   label = 'Apple',  min = 1, max = 5 },
                { item = 'carrots', label = 'Carrot', min = 1, max = 3 },
            }
        },
        outWest = false, -- Set false if This is Not in the Desert/Western Part of the Map
        radius = 10,     -- Radius from trainCoords to Stop the Train
        enabled = true   -- Set false to disable this location
    },
    -----------------------------------------------------

    -- Armadillo
    armadillo = {                                            -- Unique Key for Location
        name = 'Armadillo Station',                          -- Name of Location
        trainCoords = vector3(-3749.8, -2635.28, -13.87),    -- Stop Train for Delivery
        deliveryCoords = vector3(-3735.51, -2620.4, -13.27), -- Player Delivery Coords
        requireItem = false,                                 -- Require Item to Start Mission
        items = {                                            -- Items Required to Start Mission (ALL items listed are required to start)
            { item = 'apple', label = 'Apple', quantity = 1 },
        },
        rewards = {                        -- Rewards for Completing Mission (min/max values for random amounts)
            cash = { min = 20, max = 50 }, -- Random cash amount between min and max
            gold = { min = 1, max = 5 },   -- Random gold amount between min and max
            items = {                      -- Random quantities between min and max for each item
                { item = 'apple',   label = 'Apple',  min = 1, max = 5 },
                { item = 'carrots', label = 'Carrot', min = 1, max = 3 },
            }
        },
        outWest = true, -- Set false if This is Not in the Desert/Western Part of the Map
        radius = 10,    -- Radius from trainCoords to Stop the Train
        enabled = true  -- Set false to disable this location
    },
    -----------------------------------------------------
    -- Add as Many Locations as You Want
}
