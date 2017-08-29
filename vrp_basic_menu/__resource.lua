
description "vRP static menus"
--ui_page "ui/index.html"

dependency "vrp"

client_scripts{ 
  "client/Tunnel.lua",
  "client/Proxy.lua",
  "playerblips/client.lua",
  "runcode/client.lua"
  "drag/client.lua",
  "client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "runcode/server.lua",
  "server.lua"
}
