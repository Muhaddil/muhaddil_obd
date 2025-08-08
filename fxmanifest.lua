fx_version 'cerulean'
game 'gta5'

description 'OBD System for JG-Mechanic'
author 'Muhaddil'
version 'v1.0.22'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_script 'client/*'
server_script {
    '@mysql-async/lib/MySQL.lua',
    'server/*'
}

ui_page 'html/index.html' -- Comment this line if you want to use the minimalistic UI
-- ui_page 'html/minimalistic.html' -- Uncomment if you want to use the minimalistic UI -- Not updated yet

files {
    'html/index.html', -- Comment this line if you want to use the minimalistic UI
    -- 'html/minimalistic.html', -- Uncomment if you want to use the minimalistic UI -- Not updated yet
}
