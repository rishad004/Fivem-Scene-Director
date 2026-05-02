fx_version 'cerulean'
game 'gta5'

name 'scene-director'
author 'rishad004'
description 'Cinematic Scene Director'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/app.js',
    'web/style.css'
}

client_scripts {
    'client/main.lua',
    'client/camera.lua',
    'client/actors.lua',
    'client/animation.lua',
    'client/timeline.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'oxmysql',
    'illenium-appearance'
}