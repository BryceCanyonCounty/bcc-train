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
    'client/functions.lua',
    'client/menus/shops/main.lua',
    'client/menus/shops/*.lua',
    'client/menus/*.lua',
    'client/client.lua',
    'client/missions.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/item_utils.lua',
    'server/server.lua',
    'server/exports.lua'
}

version '2.0.0'
