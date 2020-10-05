fx_version 'adamant'

game 'gta5'

description 'ESX Status Hud'

version '1.0.0'
server_script 'server/*.lua'

client_scripts {
	'@es_extended/locale.lua',
	'locales/br.lua',
	'@esx_skin/client/main.lua',
	'client/main.lua',
}

ui_page 'skin_hud/dist/index.html'

files {
	'skin_hud/dist/index.html'
}

dependencies {
	'es_extended',
	'esx_skin',
	'skinchanger'
}