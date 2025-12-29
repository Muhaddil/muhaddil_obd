fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'OBD System for JG-Mechanic'
author 'Muhaddil'
version 'v1.0.3'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/*',
    'locales/*',
}

client_script 'client/*'
server_script {
    '@mysql-async/lib/MySQL.lua',
    'server/*'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'locales/*'
}
