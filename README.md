# bcc-train

## Description

This is the best, full fledged train script for RedM! A multitude of features like built in track switching, train inventories, ownership, lockpicking system, and more!

## Features

- **Train Ownership & Economy System**
  - Buy and Sell trains at train stations with modern menu system
  - Flexible currency system (cash only, gold only, or both)
  - Currency-aware pricing with sell confirmation menus
  - Purchased trains are stored in database with hex hash system
  - Can set a max number of trains a player can own
  - Ownership-based inventory access control

- **Enhanced Train Management**
  - Improved train spawning with proper cleanup validation
  - Train preview system when purchasing
  - Safe train selling with automatic cleanup of spawned trains
  - Return train function (despawn without selling)
  - Direction toggle for train spawning

- **Advanced Security & Lockpicking**
  - Lockpick other players' trains to access their inventories
  - Multi-lockpick item support (configurable)
  - Configurable lockpick difficulty and attempts
  - Random or static lockpick options
  - Robbery alerts for law enforcement

- **Train Operations**
  - Track Switching system
  - Configurable train speeds with cruise control option
  - Trains require fuel to operate
  - Train condition system requiring maintenance
  - Distance-based despawn system

- **Station Management**
  - Multiple train stations with individual configurations
  - Station access can be limited by job and jobgrade
  - Configurable station hours (or 24/7 operation)
  - Station blips with dynamic colors (open/closed/job-locked)
  - Distance-based NPC spawns

- **Inventory System**
  - Individual inventory size per train model
  - Shared or private inventory options
  - Inventory access based on train ownership
  - Non-owners can lockpick to access private inventories

- **Mission System**
  - Delivery missions with configurable locations
  - Server-based delivery cooldown (persists through relog)
  - Dynamic mission selection based on train region
  - Option to require items to start a mission

- **Special Features**
  - Bacchus Bridge destruction with dynamite
  - Discord webhook integration
  - Automatic database seeding
  - Multiple language support

- **Quality of Life**
  - Modern feather-menu based UI system
  - Comprehensive error handling and validation
  - Debug logging system with BCCTrainDebug integration
  - Automatic train cleanup management
  - Enhanced user feedback and notifications
  - Performance optimizations

## Dependencies

- [vorp_core](https://github.com/VORPCORE/vorp-core-lua)
- [vorp_inventory](https://github.com/VORPCORE/vorp_inventory-lua)
- [feather-menu](https://github.com/FeatherFramework/feather-menu/releases)
- [bcc-utils](https://github.com/BryceCanyonCounty/bcc-utils)
- [bcc-minigames](https://github.com/BryceCanyonCounty/bcc-minigames)
- [bcc-job-alerts](https://github.com/BryceCanyonCounty/bcc-job-alerts)

## Installation

- Download the latest release `bcc-train.zip` at [/releases/latest](https://github.com/BryceCanyonCounty/bcc-train/releases/latest)
- Add `bcc-train` folder to your resources folder
- Add `ensure bcc-train` to your `resources.cfg`
- Add images to: `...\vorp_inventory\html\img`
- Make sure dependencies are installed and ensured above `bcc-train`
- The script will automatically create database tables and seed items on first start
- Restart server

## Database Management

The script includes modern database management with migration system:

### Auto-Setup

- Automatically creates `bcc_player_trains` table on first start
- Migrates from legacy `train` table with hex hash conversion
- Seeds required items (bagofcoal, trainoil, dynamitebundle, lockpick)
- Migration system prevents duplicate seeding
- Schema validation ensures proper table structure

### Manual Commands (Server Console)

```bash
bcc-train:seed    # Force re-seed all items
bcc-train:verify  # Check if all items exist in database
bcc-train:migrate # Force database migration (if needed)
```

## Configuration

### Main Config (`configs/config.lua`)

- `currency`: Currency system (0=cash only, 1=gold only, 2=both)
- `sellPrice`: Percentage of purchase price when selling (default: 0.75)
- `autoSeedDatabase`: Enable/disable automatic database seeding
- `maxTrains`: Maximum trains per player
- `lockpickItem`: Array of items that can be used as lockpicks
- Lockpick system settings (difficulty, attempts, random degrees)
- Key bindings and webhook settings
- `trainBlips`: global train blip settings (enable, nameMode, standardName, sprite, color)
  
### Train Configuration (`configs/trains.lua`)

- Individual train models with hex hash keys
- Categorized trains: Cargo, Passenger, Mixed, Special
- Per-train fuel, condition, and inventory settings

### Delivery Locations (`configs/delivery.lua`)

- Keyed table structure for easy management
- Individual enable/disable per location
- Region-based mission selection (outWest property)

## How to Use

### Basic Controls

- Press `U` to access train inventory
- Press `G` at stations to open modern train shop menu
- Press `G` at Bacchus Bridge to destroy it (requires dynamite)
- Use `/showtrains` to create temporary coordinate blips for active trains

### Temporary Train Locator (`/showtrains`)

Players may find it useful to quickly locate active trains on the map. The `/showtrains` client command will create temporary coordinate blips for known spawned trains for a short duration.

- Usage: `/showtrains` (client-side command)
- Duration: Controlled by `Config.trainBlips.showTrains.blipDuration` (default: 10 seconds)
- Permission: A job-based permission check can be enabled in `configs/config.lua` under `Config.trainBlips.showTrains.jobsEnabled` with allowed entries in `Config.trainBlips.showTrains.jobs` (objects with `name` and `grade`).

### Train Shop System

- **Category Selection**: Choose from Cargo, Passenger, Mixed, or Special trains
- **Train Preview**: Spawns a preview train at the station when browsing
- **Purchase Confirmation**: Shows price and currency options before buying
- **Currency Selection**: Choose cash or gold payment (if both enabled)
- **My Trains**: Manage owned trains, spawn, sell, or rename

### Selling Trains

- Navigate to "My Trains" → Select train → "Sell Train"
- View sell price and choose currency to receive
- Confirm sale (automatically cleans up spawned trains)
- Sell price is percentage of purchase price (configurable)

### Lockpicking System

- Approach another player's train
- Press `U` to attempt lockpicking (requires any configured lockpick item)
- Complete the minigame to access their inventory
- Failed attempts consume lockpicks after max attempts reached

### Train Operations

- Cruise control will disengage if conductor leaves engine seat
- Fuel and condition decrease during operation
- Use bagofcoal to refuel and trainoil to repair

## API

### Check if train spawned (Server Side)

Returns true if a train has been spawned, false if no train is spawned/in-use.

```lua
local retval = exports['bcc-train']:CheckIfTrainIsSpawned()
```

### Get Train Entity (Server Side)

Returns the train entity if one exists, false if no train is spawned.

```lua
local retval = exports['bcc-train']:GetTrainEntity()
```

### Check if Bacchus Bridge Destroyed (Server Side)

Returns true if the bridge is destroyed, false if not.

```lua
local retval = exports['bcc-train']:BacchusBridgeDestroyed()
```

## Credits and Notes

- All imagery was provided by Lady Grey
- Thanks sav for the NUI

## GitHub

[bcc-train](https://github.com/BryceCanyonCounty/bcc-train)
