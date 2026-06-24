fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'samstudio'
description 'Handcuffs & headbag system'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
}

client_scripts {
    'client/init.lua',
    'client/cuffs.lua',
    'client/headbag.lua',
}

server_scripts {
    'server/init.lua',
    'server/persistence.lua',
    'server/cuffs.lua',
    'server/headbag.lua',
    'server/commands.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/js/*.js',
    'html/css/*.css',
    'html/bag.png',
    'locales/*.json',
}
