
description "vRP static menus"
--ui_page "ui/index.html"

dependency "vrp"

client_scripts{ 
  "playerblips/Proxy.lua",
  "playerblips/client.lua",
  "drag/client.lua",
  "runcode/client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "runcode/server.lua",
  "server.lua"
}
