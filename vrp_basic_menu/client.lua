--bind client tunnel interface
vRPbm = {}
Tunnel = module("vrp", "lib/Tunnel")
Proxy = module("vrp", "lib/Proxy")
lcfg = module("vrp", "cfg/base")
Tunnel.bindInterface("vRP_basic_menu",vRPbm)
vRPserver = Tunnel.getInterface("vRP","vRP_basic_menu")
HKserver = Tunnel.getInterface("vrp_hotkeys","vRP_basic_menu")
BMserver = Tunnel.getInterface("vRP_basic_menu","vRP_basic_menu")
vRP = Proxy.getInterface("vRP")

-- load global and local languages
Luang = module("vrp", "lib/Luang")
Lang = Luang()
Lang:loadLocale(lcfg.lang, module("vrp", "cfg/lang/"..lcfg.lang) or {})
Lang:loadLocale(lcfg.lang, module("vrp_basic_menu", "cfg/lang/"..lcfg.lang) or {})
lang = Lang.lang[lcfg.lang]