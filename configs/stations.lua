-----------------------------------------------------
-- Train Station Config
-----------------------------------------------------
Stations = {
    valentine = {
        shop = {
            name        = 'Valentine Station', -- Name of Station on Menu Header
            prompt      = 'Valentine Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,                 -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,               -- Allow Access to Specified Jobs Only
            jobs        = {                    -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Valentine Station', -- Name of Blip on Map
            sprite = 1258184551,          -- Default: 1258184551
            show   = {
                open = true,              -- Show Blip On Map when Open
                closed = true,            -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                            -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',       -- Model Used for NPC
            coords   = vector3(-172.9, 629.79, 114.03), -- NPC and Station Blip Positions
            heading  = 228.81,                          -- NPC Heading
            distance = 100                              -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(-163.78, 628.17, 113.52), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                            -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(-163.98, 642.17, 118.19)
        }
    },
    -----------------------------------------------------

    emerald = {
        shop = {
            name        = 'Emerald Station', -- Name of Station on Menu Header
            prompt      = 'Emerald Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,               -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,             -- Allow Access to Specified Jobs Only
            jobs        = {                  -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Emerald Station', -- Name of Blip on Map
            sprite = 1258184551,        -- Default: 1258184551
            show   = {
                open = true,            -- Show Blip On Map when Open
                closed = true,          -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                            -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',       -- Model Used for NPC
            coords   = vector3(1525.18, 442.51, 90.68), -- NPC and Station Blip Positions
            heading  = 270.86,                          -- NPC Heading
            distance = 100                              -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(1529.67, 442.54, 90.22), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                           -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(1522.99, 455.12, 96.57)
        }
    },
    -----------------------------------------------------

    flatneck = {
        shop = {
            name        = 'Flatneck Station', -- Name of Station on Menu Header
            prompt      = 'Flatneck Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,                -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,              -- Allow Access to Specified Jobs Only
            jobs        = {                   -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Flatneck Station', -- Name of Blip on Map
            sprite = 1258184551,         -- Default: 1258184551
            show   = {
                open = true,             -- Show Blip On Map when Open
                closed = true,           -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                            -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',       -- Model Used for NPC
            coords   = vector3(-330.78, -354.93, 88.01), -- NPC and Station Blip Positions
            heading  = 32.59,                          -- NPC Heading
            distance = 100                              -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(-339.0, -350.0, 87.81), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                          -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(-331.79, -334.84, 92.81)
        }
    },
    -----------------------------------------------------

    rhodes = {
        shop = {
            name        = 'Rhodes Station', -- Name of Station on Menu Header
            prompt      = 'Rhodes Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,              -- Distance Between Player and Station to Show Menu Prompt
            currency    = 1,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,            -- Allow Access to Specified Jobs Only
            jobs        = {                 -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Rhodes Station', -- Name of Blip on Map
            sprite = 1258184551,       -- Default: 1258184551
            show   = {
                open = true,           -- Show Blip On Map when Open
                closed = true,         -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                              -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',         -- Model Used for NPC
            coords   = vector3(1227.89, -1300.21, 76.91), -- NPC and Station Blip Positions
            heading  = 135.87,                            -- NPC Heading
            distance = 100                                -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(1226.74, -1310.03, 76.47), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                             -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(1241.88, -1314.45, 81.14)
        }
    },
    -----------------------------------------------------

    stdenis = {
        shop = {
            name        = 'Saint Denis Station', -- Name of Station on Menu Header
            prompt      = 'Saint Denis Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,                   -- Distance Between Player and Station to Show Menu Prompt
            currency    = 0,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,                 -- Allow Access to Specified Jobs Only
            jobs        = {                      -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Saint Denis Station', -- Name of Blip on Map
            sprite = 1258184551,            -- Default: 1258184551
            show   = {
                open = true,                -- Show Blip On Map when Open
                closed = true,              -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                             -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',        -- Model Used for NPC
            coords   = vector3(2740.0, -1405.69, 46.19), -- NPC and Station Blip Positions
            heading  = 210.56,                            -- NPC Heading
            distance = 100                               -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(2770.08, -1414.51, 45.98), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                             -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(2773.68, -1400.49, 49.99)
        }
    },
    -----------------------------------------------------

    annesburg = {
        shop = {
            name        = 'Annesburg Station', -- Name of Station on Menu Header
            prompt      = 'Annesburg Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,                 -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,               -- Allow Access to Specified Jobs Only
            jobs        = {                    -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Annesburg Station', -- Name of Blip on Map
            sprite = 1258184551,          -- Default: 1258184551
            show   = {
                open = true,              -- Show Blip On Map when Open
                closed = true,            -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                             -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',        -- Model Used for NPC
            coords   = vector3(2941.52, 1286.11, 44.64), -- NPC and Station Blip Positions
            heading  = 242.69,                            -- NPC Heading
            distance = 100                               -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(2957.25, 1281.58, 43.95), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                            -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(2956.50, 1297.97, 49.02)
        }
    },
    -----------------------------------------------------

    bacchus = {
        shop = {
            name        = 'Bacchus Station', -- Name of Station on Menu Header
            prompt      = 'Bacchus Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,               -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,             -- Allow Access to Specified Jobs Only
            jobs        = {                  -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Bacchus Station', -- Name of Blip on Map
            sprite = 1258184551,        -- Default: 1258184551
            show   = {
                open = true,            -- Show Blip On Map when Open
                closed = true,          -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                             -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',        -- Model Used for NPC
            coords   = vector3(582.49, 1681.07, 187.79), -- NPC and Station Blip Positions
            heading  = 315.88,                           -- NPC Heading
            distance = 100                               -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(581.14, 1691.8, 187.6), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                          -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(565.82, 1695.79, 193.53)
        }
    },
    -----------------------------------------------------

    wallace = {
        shop = {
            name        = 'Wallace Station', -- Name of Station on Menu Header
            prompt      = 'Wallace Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,               -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,             -- Allow Access to Specified Jobs Only
            jobs        = {                  -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Wallace Station', -- Name of Blip on Map
            sprite = 1258184551,        -- Default: 1258184551
            show   = {
                open = true,            -- Show Blip On Map when Open
                closed = true,          -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                             -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',        -- Model Used for NPC
            coords   = vector3(-1307.86, 395.86, 95.38), -- NPC and Station Blip Positions
            heading  = 61.95,                            -- NPC Heading
            distance = 100                               -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(-1307.62, 406.83, 94.98), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                            -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(-1309.86, 391.40, 101.04)
        }
    },
    -----------------------------------------------------

    riggs = {
        shop = {
            name        = 'Riggs Station', -- Name of Station on Menu Header
            prompt      = 'Riggs Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,             -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,           -- Allow Access to Specified Jobs Only
            jobs        = {                -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Riggs Station', -- Name of Blip on Map
            sprite = 1258184551,      -- Default: 1258184551
            show   = {
                open = true,          -- Show Blip On Map when Open
                closed = true,        -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                              -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',         -- Model Used for NPC
            coords   = vector3(-1098.82, -575.78, 82.39), -- NPC and Station Blip Positions
            heading  = 168.87,                              -- NPC Heading
            distance = 100                                -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(-1097.07, -583.71, 81.67), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = false,                             -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(-1083.04, -588.04, 85.81)
        }
    },
    -----------------------------------------------------

    armadillo = {
        shop = {
            name        = 'Armadillo Station', -- Name of Station on Menu Header
            prompt      = 'Armadillo Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,                 -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,               -- Allow Access to Specified Jobs Only
            jobs        = {                    -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Armadillo Station', -- Name of Blip on Map
            sprite = 1258184551,          -- Default: 1258184551
            show   = {
                open = true,              -- Show Blip On Map when Open
                closed = true,            -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                                -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',           -- Model Used for NPC
            coords   = vector3(-3733.71, -2602.73, -12.92), -- NPC and Station Blip Positions
            heading  = 75.7,                                -- NPC Heading
            distance = 100                                  -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(-3748.85, -2600.8, -13.72), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = true,                               -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(-3755.71, -2589.47, -8.75)
        }
    },
    -----------------------------------------------------

    benedict = {
        shop = {
            name        = 'Benedict Station', -- Name of Station on Menu Header
            prompt      = 'Benedict Station', -- Text Below the Menu Prompt Button
            distance    = 2.0,                -- Distance Between Player and Station to Show Menu Prompt
            currency    = 2,                   -- Default: 2 / 0 = Cash Only, 1 = Gold Only, 2 = Both
            jobsEnabled = false,              -- Allow Access to Specified Jobs Only
            jobs        = {                   -- Allowed Jobs - ex. jobs = {{name = 'police', grade = 1},{name = 'doctor', grade = 3}}
                { name = 'conductor', grade = 0 },
            },
            hours       = {
                active = false, -- Station uses Open and Closed Hours
                open   = 7,     -- Station Open Time / 24 Hour Clock
                close  = 21     -- Station Close Time / 24 Hour Clock
            }
        },
        blip = {
            name   = 'Benedict Station', -- Name of Blip on Map
            sprite = 1258184551,         -- Default: 1258184551
            show   = {
                open = true,             -- Show Blip On Map when Open
                closed = true,           -- Show Blip On Map when Closed
            },
            color  = {
                open   = 'WHITE',        -- Station Open - Default: White - Blip Colors Shown Below
                closed = 'RED',          -- Station Closed - Deafault: Red - Blip Colors Shown Below
                job    = 'YELLOW_ORANGE' -- Station Job Locked - Default: Yellow - Blip Colors Shown Below
            }
        },
        npc = {
            active   = true,                                -- Turns NPC On / Off
            model    = 's_m_m_sdticketseller_01',           -- Model Used for NPC
            coords   = vector3(-5230.56, -3470.81, -20.57), -- NPC and Station Blip Positions
            heading  = 88.7,                                -- NPC Heading
            distance = 100                                  -- Distance Between Player and Station for NPC to Spawn
        },
        train = {
            coords  = vector3(-5235.54, -3473.3, -21.25), -- Make Sure the Coord Here is Directly on Top of the Track You Want the Train to Spawn On!
            outWest = true,                               -- Set false if This is Not in the Desert/Western Part of the Map
            camera  = vector3(-5228.17, -3486.36, -16.02)
        }
    },
    -----------------------------------------------------
}
