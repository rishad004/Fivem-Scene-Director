fx_version 'cerulean'
game 'gta5'

name 'fivem-scene-director'
description 'Standalone Scene Director with Character Creator'
author 'rishad004'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/app.js',
    'web/style.css'
}

client_scripts {
    'client/main.lua',
    'client/camera.lua',
    'client/character.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'oxmysql',
    'illenium-appearance'
}
