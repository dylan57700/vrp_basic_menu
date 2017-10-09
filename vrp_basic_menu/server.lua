local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
local htmlEntities = module("vrp", "lib/htmlEntities")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_basic_menu")
BMclient = Tunnel.getInterface("vRP_basic_menu","vRP_basic_menu")
vRPbsC = Tunnel.getInterface("vRP_barbershop","vRP_basic_menu")

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

-- teleport waypoint
local choice_tptowaypoint = {function(player,choice)
  TriggerClientEvent("TpToWaypoint", player)
end, "Teleport to map blip."}

-- fix barbershop green hair for now
local ch_fixhair = {function(player,choice)
    local custom = {}
    local user_id = vRP.getUserId({player})
    vRP.getUData({user_id,"vRP:head:overlay",function(value)
	  if value ~= nil then
	    custom = json.decode(value)
        vRPbsC.setOverlay(player,{custom,true})
	  end
	end})
end, "Fix the barbershop bug for now."}

--toggle blips
local ch_blips = {function(player,choice)
  TriggerClientEvent("showBlips", player)
end, "Toggle blips."}

local ch_sprites = {function(player,choice)
  TriggerClientEvent("showSprites", player)
end, "Toggle sprites."}

local ch_deleteveh = {function(player,choice)
  BMclient.deleteNearestVehicle(player,{5})
end, "Delete nearest car."}

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

--police weapons // comment out the weapons if you dont want to give weapons.
local police_weapons = {}
police_weapons["Equip"] = {function(player,choice)
    vRPclient.giveWeapons(player,{{
	  ["WEAPON_COMBATPISTOL"] = {ammo=200},
	  ["WEAPON_PUMPSHOTGUN"] = {ammo=200},
	  ["WEAPON_NIGHTSTICK"] = {ammo=200},
	  ["WEAPON_STUNGUN"] = {ammo=200}
	}, true})
	BMclient.setArmour(player,{100,true})
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
end, "Store your money in your inventory."}

--medkit storage
local emergency_medkit = {}
emergency_medkit["Take"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRP.giveInventoryItem({user_id,"medkit",25,true})
	vRP.giveInventoryItem({user_id,"pills",25,true})
end}

--heal me
local emergency_heal = {}
emergency_heal["Heal"] = {function(player,choice)
	local user_id = vRP.getUserId({player}) 
	vRPclient.setHealth(player,{1000})
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
			local revive_seq = {
			  {"amb@medic@standing@kneel@enter","enter",1},
			  {"amb@medic@standing@kneel@idle_a","idle_a",1},
			  {"amb@medic@standing@kneel@exit","exit",1}
			}
  			vRPclient.playAnim(player,{false,revive_seq,false}) -- anim
            SetTimeout(15000, function()
              local ndata = vRP.getUserDataTable({nuser_id})
              if ndata ~= nil then
			    if ndata.inventory ~= nil then -- gives inventory items
				  vRP.clearInventory({nuser_id})
                  for k,v in pairs(ndata.inventory) do 
			        vRP.giveInventoryItem({user_id,k,v.amount,true})
	              end
				end
			  end
            end)
			vRPclient.stopAnim(player,{false})
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

-- hack player
local ch_hack = {function(player,choice)
  -- get nearest player
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{25},function(nplayer)
      if nplayer ~= nil then
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
          -- prompt number
		  local nbank = vRP.getBankMoney({nuser_id})
          local amount = math.floor(nbank*0.01)
		  local nvalue = nbank - amount
		  if math.random(1,100) == 1 then
			vRP.setBankMoney({nuser_id,nvalue})
            vRPclient.notify(nplayer,{"Hacked ~r~".. amount .."$."})
		    vRP.giveInventoryItem({user_id,"dirty_money",amount,true})
		  else
            vRPclient.notify(nplayer,{"~g~Hacking attempt failed."})
            vRPclient.notify(player,{"~r~Hacking attempt failed."})
		  end
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end,"Hack closest player."}

-- mug player
local ch_mug = {function(player,choice)
  -- get nearest player
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      if nplayer ~= nil then
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
          -- prompt number
		  local nmoney = vRP.getMoney({nuser_id})
          local amount = nmoney
		  if math.random(1,3) == 1 then
            if vRP.tryPayment({nuser_id,amount}) then
              vRPclient.notify(nplayer,{"Mugged ~r~"..amount.."$."})
		      vRP.giveInventoryItem({user_id,"dirty_money",amount,true})
            else
              vRPclient.notify(player,{lang.money.not_enough()})
            end
		  else
            vRPclient.notify(nplayer,{"~g~Mugging attempt failed."})
            vRPclient.notify(player,{"~r~Mugging attempt failed."})
		  end
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end, "Mug closest player."}

-- drag player
local ch_drag = {function(player,choice)
  -- get nearest player
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getNearestPlayer(player,{10},function(nplayer)
      if nplayer ~= nil then
        local nuser_id = vRP.getUserId({nplayer})
        if nuser_id ~= nil then
		  vRPclient.isHandcuffed(nplayer,{},function(handcuffed)
			if handcuffed then
				TriggerClientEvent("dr:drag", nplayer, player)
			else
				vRPclient.notify(player,{"Player is not handcuffed."})
			end
		  end)
        else
          vRPclient.notify(player,{lang.common.no_player_near()})
        end
      else
        vRPclient.notify(player,{lang.common.no_player_near()})
      end
    end)
  end
end, "Drag closest player."}

-- player check
local choice_player_check = {function(player,choice)
  vRPclient.getNearestPlayer(player,{5},function(nplayer)
    local nuser_id = vRP.getUserId({nplayer})
    if nuser_id ~= nil then
      vRPclient.notify(nplayer,{lang.police.menu.check.checked()})
      vRPclient.getWeapons(nplayer,{},function(weapons)
        -- prepare display data (money, items, weapons)
        local money = vRP.getMoney({nuser_id})
        local items = ""
        local data = vRP.getUserDataTable({nuser_id})
        if data and data.inventory then
          for k,v in pairs(data.inventory) do
            local item = vRP.items[k]
            if item then
              items = items.."<br />"..item.name.." ("..v.amount..")"
            end
          end
        end

        local weapons_info = ""
        for k,v in pairs(weapons) do
          weapons_info = weapons_info.."<br />"..k.." ("..v.ammo..")"
        end

        vRPclient.setDiv(player,{"police_check",".div_police_check{ background-color: rgba(0,0,0,0.75); color: white; font-weight: bold; width: 500px; padding: 10px; margin: auto; margin-top: 150px; }",lang.police.menu.check.info({money,items,weapons_info})})
        -- request to hide div
        vRP.request({player, lang.police.menu.check.request_hide(), 1000, function(player,ok)
          vRPclient.removeDiv(player,{"police_check"})
        end})
      end)
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end, lang.police.menu.check.description()}

-- player store weapons
local choice_store_weapons = {function(player, choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    vRPclient.getWeapons(player,{},function(weapons)
      for k,v in pairs(weapons) do
        -- convert weapons to parametric weapon items
        vRP.giveInventoryItem({user_id, "wbody|"..k, 1, true})
        if v.ammo > 0 then
          vRP.giveInventoryItem({user_id, "wammo|"..k, v.ammo, true})
        end
      end

      -- clear all weapons
      vRPclient.giveWeapons(player,{{},true})
    end)
  end
end, lang.police.menu.store_weapons.description()}

-- armor item
vRP.defInventoryItem({"body_armor","Body Armor","",
function(args)
  local choices = {}

  choices["Equip"] = {function(player,choice)
    local user_id = vRP.getUserId({player})
    if user_id ~= nil then
      if vRP.tryGetInventoryItem({user_id, "body_armor", 1, true}) then
		BMclient.setArmour(player,{100,true})
        vRP.closeMenu({player})
      end
    end
  end}

  return choices
end,
5.00})

-- store armor
local choice_store_armor = {function(player, choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    BMclient.getArmour(player,{},function(armour)
      if armour > 95 then
        vRP.giveInventoryItem({user_id, "body_armor", 1, true})
        -- clear armor
	    BMclient.setArmour(player,{0,false})
	  else
	    vRPclient.notify(player, {"~r~Damaged armor can't be stored!"})
      end
    end)
  end
end, "Store intact body armor in inventory."}

local unjailed = {}
function jail_clock(target_id,timer)
  local target = vRP.getUserSource({tonumber(target_id)})
  local users = vRP.getUsers({})
  local online = false
  for k,v in pairs(users) do
	if tonumber(k) == tonumber(target_id) then
	  online = true
	end
  end
  if online then
    if timer>0 then
	  vRPclient.notify(target, {"~r~Remaining time: " .. timer .. " minute(s)."})
      vRP.setUData({tonumber(target_id),"vRP:jail:time",json.encode(timer)})
	  SetTimeout(60*1000, function()
		for k,v in pairs(unjailed) do -- check if player has been unjailed by cop or admin
		  if v == tonumber(target_id) then
	        unjailed[v] = nil
		    timer = 0
		  end
		end
	    jail_clock(tonumber(target_id),timer-1)
	  end) 
    else 
	  BMclient.loadFreeze(target,{true})
	  SetTimeout(15000,function()
		BMclient.loadFreeze(target,{false})
	  end)
	  vRPclient.teleport(target,{425.7607421875,-978.73425292969,30.709615707397}) -- teleport to outside jail
	  vRPclient.setHandcuffed(target,{false})
      vRPclient.notify(target,{"~b~You have been set free."})
	  vRP.setUData({tonumber(target_id),"vRP:jail:time",json.encode(-1)})
    end
  end
end

-- dynamic jail
local ch_jail = {function(player,choice) 
  vRPclient.getNearestPlayers(player,{15},function(nplayers) 
	local user_list = ""
    for k,v in pairs(nplayers) do
	  user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. GetPlayerName(k) .. " | "
    end 
	if user_list ~= "" then
	  vRP.prompt({player,"Players Nearby:" .. user_list,"",function(player,target_id) 
	    if target_id ~= nil and target_id ~= "" then 
	      vRP.prompt({player,"Jail Time in minutes:","1",function(player,jail_time)
			if jail_time ~= nil and jail_time ~= "" then 
	          local target = vRP.getUserSource({tonumber(target_id)})
			  if target then
		        if tonumber(jail_time) > 30 then
  			      jail_time = 30
		        end
		        if tonumber(jail_time) < 1 then
		          jail_time = 1
		        end
		  
                vRPclient.isHandcuffed(target,{}, function(handcuffed)  
                  if handcuffed then 
					BMclient.loadFreeze(target,{true})
					SetTimeout(15000,function()
					  BMclient.loadFreeze(target,{false})
					end)
				    vRPclient.teleport(target,{1641.5477294922,2570.4819335938,45.564788818359}) -- teleport to inside jail
				    vRPclient.notify(target,{"~r~You have been sent to jail."})
				    vRPclient.notify(player,{"~b~You sent a player to jail."})
				    vRP.setHunger({tonumber(target_id),0})
				    vRP.setThirst({tonumber(target_id),0})
				    jail_clock(tonumber(target_id),tonumber(jail_time))
			      else
				    vRPclient.notify(player,{"~r~That player is not handcuffed."})
			      end
			    end)
			  else
				vRPclient.notify(player,{"~r~That ID seems invalid."})
			  end
			else
			  vRPclient.notify(player,{"~r~The jail time can't be empty."})
			end
	      end})
        else
          vRPclient.notify(player,{"~r~No player ID selected."})
        end 
	  end})
    else
      vRPclient.notify(player,{"~r~No player nearby."})
    end 
  end)
end,"Send a nearby player to jail."}

-- dynamic unjail
local ch_unjail = {function(player,choice) 
	vRP.prompt({player,"Player ID:","",function(player,target_id) 
	  if target_id ~= nil and target_id ~= "" then 
		vRP.getUData({tonumber(target_id),"vRP:jail:time",function(value)
		  if value ~= nil then
		  custom = json.decode(value)
			if custom ~= nil then
			  local user_id = vRP.getUserId({player})
			  if tonumber(custom) > 0 or vRP.hasPermission({user_id,"admin.easy_unjail"}) then
	            local target = vRP.getUserSource({tonumber(target_id)})
				if target then
	              unjailed[target] = tonumber(target_id)
				  vRPclient.notify(player,{"~g~Target will be released soon."})
				  vRPclient.notify(target,{"~g~Someone lowered your sentence."})
				else
				  vRPclient.notify(player,{"~r~That ID seems invalid."})
				end
			  else
				vRPclient.notify(player,{"~r~Target is not jailed."})
			  end
			end
		  end
		end})
      else
        vRPclient.notify(player,{"~r~No player ID selected."})
      end 
	end})
end,"Frees a jailed player."}

-- (server) called when a logged player spawn to check for vRP:jail in user_data
AddEventHandler("vRP:playerSpawn", function(user_id, source, first_spawn) 
  local target = vRP.getUserSource({user_id})
  SetTimeout(35000,function()
    local custom = {}
    vRP.getUData({user_id,"vRP:jail:time",function(value)
	  if value ~= nil then
	    custom = json.decode(value)
	    if custom ~= nil then
		  if tonumber(custom) > 0 then
			BMclient.loadFreeze(target,{true})
			SetTimeout(15000,function()
			  BMclient.loadFreeze(target,{false})
			end)
            vRPclient.setHandcuffed(target,{true})
            vRPclient.teleport(target,{1641.5477294922,2570.4819335938,45.564788818359}) -- teleport inside jail
            vRPclient.notify(target,{"~r~Finish your sentence."})
			vRP.setHunger({tonumber(user_id),0})
			vRP.setThirst({tonumber(user_id),0})
		    jail_clock(tonumber(user_id),tonumber(custom))
		  end
	    end
	  end
	end})
  end)
end)

-- dynamic fine
local ch_fine = {function(player,choice) 
  vRPclient.getNearestPlayers(player,{15},function(nplayers) 
	local user_list = ""
    for k,v in pairs(nplayers) do
	  user_list = user_list .. "[" .. vRP.getUserId({k}) .. "]" .. GetPlayerName(k) .. " | "
    end 
	if user_list ~= "" then
	  vRP.prompt({player,"Players Nearby:" .. user_list,"",function(player,target_id) 
	    if target_id ~= nil and target_id ~= "" then 
	      vRP.prompt({player,"Fine amount:","100",function(player,fine)
			if fine ~= nil and fine ~= "" then 
	          vRP.prompt({player,"Fine reason:","",function(player,reason)
			    if reason ~= nil and reason ~= "" then 
	              local target = vRP.getUserSource({tonumber(target_id)})
		  
		          if tonumber(fine) > 1000 then
  			        fine = 1000
		          end
		          if tonumber(fine) < 100 then
		            fine = 100
		          end
			  
		          if vRP.tryFullPayment({tonumber(target_id), tonumber(fine)}) then
                    vRP.insertPoliceRecord({tonumber(target_id), lang.police.menu.fine.record({reason,fine})})
                    vRPclient.notify(player,{lang.police.menu.fine.fined({reason,fine})})
                    vRPclient.notify(target,{lang.police.menu.fine.notify_fined({reason,fine})})
                    vRP.closeMenu({player})
                  else
                    vRPclient.notify(player,{lang.money.not_enough()})
                  end
				else
				  vRPclient.notify(player,{"~r~You can't fine for no reason."})
				end
	          end})
			else
			  vRPclient.notify(player,{"~r~Your fine has to have a value."})
			end
	      end})
        else
          vRPclient.notify(player,{"~r~No player ID selected."})
        end 
	  end})
    else
      vRPclient.notify(player,{"~r~No player nearby."})
    end 
  end)
end,"Fines a nearby player."}

-- improved handcuff
local ch_handcuff = {function(player,choice)
  vRPclient.getNearestPlayer(player,{10},function(nplayer)
    local nuser_id = vRP.getUserId({nplayer})
    if nuser_id ~= nil then
      vRPclient.toggleHandcuff(nplayer,{})
      vRP.closeMenu({nplayer})
    else
      vRPclient.notify(player,{lang.common.no_player_near()})
    end
  end)
end,lang.police.menu.handcuff.description()}

-- admin god mode
local gods = {}
function task_god()
  SetTimeout(10000, task_god)

  for k,v in pairs(gods) do
    vRP.setHunger({v, 0})
    vRP.setThirst({v, 0})

    local player = vRP.getUserSource({v})
    if player ~= nil then
      vRPclient.setHealth(player, {200})
    end
  end
end
task_god()

local ch_godmode = {function(player,choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    if gods[player] then
	  gods[player] = nil
	else
	  gods[player] = user_id
	end
  end
end, "Toggles admin godmode."}

local player_lists = {}
local ch_userlist = {function(player,choice)
  local user_id = vRP.getUserId({player})
  if user_id ~= nil then
    if player_lists[player] then -- hide
      player_lists[player] = nil
      vRPclient.removeDiv(player,{"user_list"})
    else -- show
      local content = "ID => NICKNAME | FIRSTNAME NAME | JOB"
      local count = 0
	  local users = vRP.getUsers({})
      for k,v in pairs(users) do
        count = count+1
        local source = vRP.getUserSource({k})
        vRP.getUserIdentity({k, function(identity)
		  if source ~= nil then
            content = content.."<br />"..k.." => <span class=\"pseudo\">"..vRP.getPlayerName({source}).."</span>"
            if identity then
              content = content.." | <span class=\"name\">"..htmlEntities.encode(identity.firstname).." "..htmlEntities.encode(identity.name).."</span> | <span class=\"job\">"..vRP.getUserGroupByType({k,"job"}).."</span>"
            end
          end
		  
          -- check end
          count = count-1
          if count == 0 then
            player_lists[player] = true
            local css = [[
              .div_user_list{ 
                margin: auto; 
				text-align: center;
                padding: 8px; 
                width: 650px; 
                margin-top: 80px; 
                background: black; 
                color: white; 
                font-weight: bold; 
                font-size: 1.1em;
              } 
              .div_user_list .pseudo{ 
                color: rgb(66, 244, 107);
              }
              .div_user_list .name{ 
                color: rgb(92, 170, 249);
              }
			  .div_user_list .job{ 
                color: rgb(247, 193, 93);
			  }
            ]]
            vRPclient.setDiv(player,{"user_list", css, content})
          end
		end})
      end
    end
  end
end, "Toggles Userlist."}

-- ADD STATIC MENU CHOICES // STATIC MENUS NEED TO BE ADDED AT vRP/cfg/gui.lua
vRP.addStaticMenuChoices({"police_weapons", police_weapons}) -- police gear
vRP.addStaticMenuChoices({"emergency_medkit", emergency_medkit}) -- pills and medkits
vRP.addStaticMenuChoices({"emergency_heal", emergency_heal}) -- heal button

-- REMEMBER TO ADD THE PERMISSIONS FOR WHAT YOU WANT TO USE
-- CREATES PLAYER SUBMENU AND ADD CHOICES
local ch_player_menu = {function(player,choice)
	local user_id = vRP.getUserId({player})
	local menu = {}
	menu.name = "Player"
	menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
    menu.onclose = function(player) vRP.openMainMenu({player}) end -- nest menu
	
    if vRP.hasPermission({user_id,"player.store_money"}) then
      menu["Store money"] = choice_store_money -- transforms money in wallet to money in inventory to be stored in houses and cars
    end
	
    if vRP.hasPermission({user_id,"player.fix_haircut"}) then
      menu["Fix Haircut"] = ch_fixhair -- just a work around for barbershop green hair bug while I am busy
    end
	
    if vRP.hasPermission({user_id,"player.userlist"}) then
      menu["User List"] = ch_userlist -- a user list for players with vRP ids, player name and identity names only.
    end
	
    if vRP.hasPermission({user_id,"player.store_weapons"}) then
      menu["Store weapons"] = choice_store_weapons -- store player weapons, like police store weapons from vrp
    end
	
    if vRP.hasPermission({user_id,"player.store_armor"}) then
      menu["Store armor"] = choice_store_armor -- store player armor
    end
	
    if vRP.hasPermission({user_id,"player.check"}) then
      menu["Inspect"] = choice_player_check -- checks nearest player inventory, like police check from vrp
    end
	
	vRP.openMenu({player, menu})
end}

-- REGISTER MAIN MENU CHOICES
vRP.registerMenuBuilder({"main", function(add, data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
    if vRP.hasPermission({user_id,"player.player_menu"}) then
      choices["Player"] = ch_player_menu -- opens player submenu
    end
	
    if vRP.hasPermission({user_id,"toggle.service"}) then
      choices["Service"] = choice_service -- toggle the receiving of missions
    end
	
    if vRP.hasPermission({user_id,"player.loot"}) then
      choices["Loot"] = choice_loot -- take the items of nearest player in coma
    end
	
    if vRP.hasPermission({user_id,"mugger.mug"}) then
      choices["Mug"] = ch_mug -- steal nearest player wallet
    end
	
    if vRP.hasPermission({user_id,"hacker.hack"}) then
      choices["Hack"] = ch_hack --  1 in 100 chance of stealing 1% of nearest player bank
    end
	
    add(choices)
  end
end})

-- RESGISTER ADMIN MENU CHOICES
vRP.registerMenuBuilder({"admin", function(add, data)
  local user_id = vRP.getUserId({data.player})
  if user_id ~= nil then
    local choices = {}
	
	if vRP.hasPermission({user_id,"admin.deleteveh"}) then
      choices["@DeleteVeh"] = ch_deleteveh -- Delete nearest vehicle (Fixed pull request https://github.com/Sighmir/vrp_basic_menu/pull/11/files/419405349ca0ad2a215df90cfcf656e7aa0f5e9c from benjatw)
	end
	
	if vRP.hasPermission({user_id,"admin.godmode"}) then
      choices["@Godmode"] = ch_godmode -- Toggles admin godmode (Disable the default admin.god permission to use this!) 
	end
	
    if vRP.hasPermission({user_id,"player.blips"}) then
      choices["@Blips"] = ch_blips -- turn on map blips and sprites
    end
	
    if vRP.hasPermission({user_id,"player.sprites"}) then
      choices["@Sprites"] = ch_sprites -- turn on only name sprites
    end
	
    if vRP.hasPermission({user_id,"admin.crun"}) then
      choices["@Crun"] = ch_crun -- run any client command, any GTA V client native http://www.dev-c.com/nativedb/
    end
	
    if vRP.hasPermission({user_id,"admin.srun"}) then
      choices["@Srun"] = ch_srun -- run any server command, any GTA V server native http://www.dev-c.com/nativedb/
    end

	if vRP.hasPermission({user_id,"player.tptowaypoint"}) then
      choices["@TpToWaypoint"] = choice_tptowaypoint -- teleport user to map blip
	end
	
	if vRP.hasPermission({user_id,"admin.easy_unjail"}) then
      choices["@UnJail"] = ch_unjail -- Un jails chosen player if he is jailed (Use admin.easy_unjail as permission to have this in admin menu working in non jailed players)
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
      choices["Store money"] = choice_store_money -- transforms money in wallet to money in inventory to be stored in houses and cars
    end
	
	if vRP.hasPermission({user_id,"police.easy_jail"}) then
      choices["Easy Jail"] = ch_jail -- Send a nearby handcuffed player to jail with prompt for choice and user_list
    end
	
	if vRP.hasPermission({user_id,"police.easy_unjail"}) then
      choices["Easy UnJail"] = ch_unjail -- Un jails chosen player if he is jailed (Use admin.easy_unjail as permission to have this in admin menu working in non jailed players)
    end
	
	if vRP.hasPermission({user_id,"police.easy_fine"}) then
      choices["Easy Fine"] = ch_fine -- Fines closeby player
    end
	
	if vRP.hasPermission({user_id,"police.easy_cuff"}) then
      choices["Easy Cuff"] = ch_handcuff -- Toggle cuffs AND CLOSE MENU for nearby player
    end
	
    if vRP.hasPermission({user_id,"police.drag"}) then
      choices["Drag"] = ch_drag -- Drags closest handcuffed player
    end
	
    add(choices)
  end
end})
