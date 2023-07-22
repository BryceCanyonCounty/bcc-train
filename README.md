# bcc-train
> This is a full fledged train script for RedM! A multitude of features like built in track switching, train inventories, ownership and more!

# Features
- Track Switching
- Multiple train stations
- Job locked
- Purchasable trains which are stored in a database
- Each train has thier own inventory
- Config option to allow cruise control
- Configurable train speeds
- Trains need fuel to run
- Maintain the train to keep it functional

## Api
### Check if train spawned!
- To check if a train has been spawned/is in-use (This is useful as only 1 train should be spawned at a time on a server typically)
```Lua
local retval = exports['bcc-train']:CheckIfTrainIsSpawned()
```
- Returns true if a train has been spawned false if no train is spawned/in-use

# Side Notes
- Thanks to our in house designer Lady Grey for all the images