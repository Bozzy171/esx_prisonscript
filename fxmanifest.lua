fx_version 'adamant'

game 'gta5'

description 'Prison script'
lua54 'yes'
version '1.0'

shared_scripts {
    '@ox_lib/init.lua'
}
client_scripts {
    'client/c.lua',
    '@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
}
server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/s.lua',
}
