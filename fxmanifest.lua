fx_version "adamant"
games { "rdr3" }
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."

lua54 "yes"

shared_scripts {
  "config.lua",
  'locale.lua',
  'languages/*.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  "/server/server.lua",
  "/server/exports.lua"
}

client_scripts {
  "/client/functions.lua",
  "/client/client.lua",
  '/client/menuSetup.lua'
}

ui_page {
  'ui/index.html'
}

files {
  'imgs/trainImg.png',
  "ui/index.html",
  "ui/js/*.*",
  "ui/css/*.*",
  "ui/fonts/*.*",
}

version "1.0.2"
