fx_version 'adamant'
games {'gta5'}

author 'gegen#4674'
version '0.0.0'
description 'JCRP Toolbox'


client_scripts {
    "k9-client.lua",
    "nui-c.lua",
    "actions.lua"
}
server_scripts {
    "k9-server.js",
    "server.lua"
}

ui_page "public/index.html"
files {
    'public/index.html',
    'public/asset-manifest.json',
    'public/static/css/*.css',
    'public/static/js/*.js',
}