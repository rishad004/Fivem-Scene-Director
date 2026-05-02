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
    'client/animation_list.lua',  -- must load first (Animations table used by others)
    'client/camera.lua',
    'client/actors.lua',
    'client/animation.lua',
    'client/timeline.lua',
    'client/creator.lua',
    'client/scene_storage.lua',   -- after Actors + Timeline are defined
    'client/main.lua'             -- NUI callbacks last
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'oxmysql',
    'illenium-appearance'
}