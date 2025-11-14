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
    'client/train_state.lua',
    'client/train_models.lua',
    'client/train_spawn.lua',
    'client/prompts.lua',
    'client/active_trains.lua',
    'client/blips_npc.lua',
    'client/spawn_and_handlers.lua',
    'client/commands.lua',
    'client/missions_init.lua',
    'client/missions_player.lua',
    'client/menus/shops/main.lua',
    'client/menus/shops/*.lua',
    'client/menus/*.lua',
    'client/test_commands.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/server.lua',
    'server/exports.lua'
}

version '2.0.0'
