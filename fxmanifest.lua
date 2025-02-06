fx_version 'cerulean'
game 'gta5'

author 'Akuamarin'
description 'QBCore Silah Kaçakçılığı Sistemi'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/tr.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/menus.lua',
    'client/events.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/events.lua'
}

dependencies {
    'qb-core',
    'oxmysql'
} 