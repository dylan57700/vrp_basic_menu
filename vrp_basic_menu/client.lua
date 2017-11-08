--bind client tunnel interface
vRPbm = {}
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")

Tunnel.bindInterface("vrp_basic_menu",vRPbm)
vRPserver = Tunnel.getInterface("vRP")
HKserver = Tunnel.getInterface("vrp_hotkeys")
BMserver = Tunnel.getInterface("vrp_basic_menu")
vRP = Proxy.getInterface("vRP")

--[[ load global and local languages (Does not work on client? Yet? I'm a noob again? Yes.)
lcfg = module("vrp", "cfg/base")
Luang = module("vrp", "lib/Luang")
Lang = Luang()
Lang:loadLocale(lcfg.lang, module("vrp", "cfg/lang/"..lcfg.lang) or {})
Lang:loadLocale(lcfg.lang, module("vrp_basic_menu", "cfg/lang/"..lcfg.lang) or {})
lang = Lang.lang[lcfg.lang]
]]