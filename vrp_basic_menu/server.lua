local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_static_menus")

local Lang = module("vrp", "lib/Lang")
local cfg = module("vrp", "cfg/base")
local lang = Lang.new(module("vrp", "cfg/lang/"..cfg.lang) or {})

-- MAKE CHOICES

--toggle service
local choice_service = {function(player,choice)
  local user_id = vRP.getUserId({player})
  local service = "onservice"
  if user_id ~= nil then
    if vRP.hasGroup({user_id,service}) then
	  vRP.removeUserGroup({user_id,service})
	  if vRP.hasMission({player}) then
		vRP.stopMission({player})
	  end
      vRPclient.notify(player,{"~r~Off service"})
	else
	  vRP.addUserGroup({user_id,service})
      vRPclient.notify(player,{"~g~On service"})
	end
  end
end, "Go on/off service"}

--toggle blips
local ch_blips = {function(player,choice)
  TriggerClientEvent("showBlips", player)
end, "Toggle blips."}

--client function
local ch_crun = {function(player,choice)
  vRP.prompt({player,"Function:","",function(player,stringToRun) 
    stringToRun = stringToRun or ""
	TriggerClientEvent("RunCode:RunStringLocally", player, stringToRun)
  end})
end, "Run client function."}

--server function
local ch_srun = {function(player,choice)
  vRP.prompt({player,"Function:","",function(player,stringToRun) 
    stringToRun = stringToRun or ""
	TriggerEvent("RunCode:RunStringRemotelly", stringToRun)
  end})
end, "Run server function."}

--police weapons
local police_weapons = {}
police_weapons["Equip"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
	  ["WEAPON_COMBATPISTOL"] = {ammo=200},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=200},
	  ["WEAPON_NIGHTSTICK"] = {ammo=200},
	  ["WEAPON_STUNGUN"] = {ammo=200}
	}, true})
end}

--store money
local choice_store_money = {function(player, choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    local amount = vRP.getMoney({user_id})
    if vRP.tryPayment({user_id, amount}) then -- unpack the money
      vRP.giveInventoryItem({user_id, "money", amount, true})
    end
  end
end, lang.police.menu.store_money.description()}

--medkit storage
local emergency_medkit = {}
emergency_medkit["Take"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRP.giveInventoryItem({user_id,"medkit",25,true})
	vRP.giveInventoryItem({user_id,"pills",25,true})
end}

--loot corpse
local choice_loot = {function(player,choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      local nuser_id = vRP.getUserId({nplayer})
      if nuser_id ~= nil then
        vRPclient.isInComa(nplayer,{}, function(in_coma)
          if in_coma then
              local ndata = vRP.getUserDataTable({nuser_id})
              if ndata ~= nil then
  			    vRPclient.playAnim(player,{false,revive_seq,false}) -- anim
                SetTimeout(15000, function()
				  if ndata.inventory ~= nil then -- gives inventory items
                    for k,v in pairs(ndata.inventory) do 
					  vRP.giveInventoryItem({user_id,k,v.amount,true})
	                end
					vRP.clearInventory({nuser_id})
				  end
                end)
			  end
          else
            vRPclient.notify(player,{lang.emergency.menu.revive.not_in_coma()})
          end
        end)
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end,"Loot nearby corpse"}

-- ADD STATIC MENU CHOICES
vRP.addStaticMenuChoices({"police_weapons", police_weapons})
vRP.addStaticMenuChoices({"emergency_medkit", emergency_medkit})

-- REGISTER MAIN MENU CHOICES
vRP.registerMenuBuilder({"main", function(add, data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
    if vRP.hasPermission({user_id,"toggle.service"}) then
      choices["Service"] = choice_service
    end
	
    if vRP.hasPermission({user_id,"player.loot"}) then
      choices["Loot"] = choice_loot
    end
	
    add(choices)
  end
end})

-- RESGISTER ADMIN MENU CHOICES
vRP.registerMenuBuilder({"admin", function(add, data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
    if vRP.hasPermission({user_id,"player.blips"}) then
      choices["@Blips"] = ch_blips
    end
	
    if vRP.hasPermission({user_id,"admin.crun"}) then
      choices["@Crun"] = ch_crun
    end
	
    if vRP.hasPermission({user_id,"admin.srun"}) then
      choices["@Srun"] = ch_srun
    end
	
    add(choices)
  end
end})

-- REGISTER POLICE MENU CHOICES
vRP.registerMenuBuilder({"police", function(add, data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
    if vRP.hasPermission({user_id,"police.store_money"}) then
      choices["Store money"] = choice_store_money
    end
    add(choices)
  end
end})