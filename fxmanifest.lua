fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

game 'rdr3'
lua54 'yes'
author 'BCC Team'

shared_scripts {
    'configs/*.lua',
    'configs/trains/*.lua',
    'debug_init.lua',
    'locale.lua',
    'languages/*.lua'
}

client_scripts {
    'client/client_init.lua',
    'client/prompts.lua',
    'client/active_trains.lua',
    'client/blips_npc.lua',
    'client/train_spawning.lua',
    'client/train_handlers.lua',
    'client/main_loop.lua',
    'client/events.lua',
    'client/missions_init.lua',
    'client/missions_player.lua',
    'client/menus/shops/main.lua',
    'client/menus/shops/*.lua',
    'client/menus/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/server_init.lua',
    'server/train_shop.lua',
    'server/train_operations.lua',
    'server/train_inventory.lua',
    'server/missions.lua',
    'server/events.lua',
    'server/exports.lua'
}

version '2.0.1'
