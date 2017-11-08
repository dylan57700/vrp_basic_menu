
-- teleport waypoint
choice_tptowaypoint = {function(player,choice)
  Citizen.CreateThread(function() 
	BMclient.tpToWaypoint(player)
  end)
end, lang.tptowaypoint.desc()}

-- toggle blips
ch_blips = {function(player,choice)
  Citizen.CreateThread(function() 
	BMclient.showBlips(player)
  end)
end, lang.blips.desc()}

-- toggle sprites
ch_sprites = {function(player,choice)
  Citizen.CreateThread(function() 
	BMclient.showSprites(player)
  end)
end, lang.sprites.desc()}

-- delete vehicle
ch_deleteveh = {function(player,choice)
  Citizen.CreateThread(function() 
	BMclient.deleteVehicleInFrontOrInside(player,5.0)
  end)
end, lang.deleteveh.desc()}

-- client function
local ch_crun = {function(player,choice)
  Citizen.CreateThread(function() 
    vRP.prompt(player,lang.crun.prompt(),"",function(player,stringToRun) 
      stringToRun = stringToRun or ""
	  BMclient.runStringLocally(player, stringToRun)
    end)
  end)
end, lang.crun.desc()}

-- server function
local ch_srun = {function(player,choice)
  Citizen.CreateThread(function() 
    vRP.prompt(player,lang.srun.prompt(),"",function(player,stringToRun) 
      stringToRun = stringToRun or ""
	  vRPbm.runStringRemotelly(stringToRun)
    end)
  end)
end, lang.srun.desc()}

-- godmode
local ch_godmode = {function(player,choice)
  Citizen.CreateThread(function() 
    local user_id = vRP.getUserId(player)
    if user_id ~= nil then
      if gods[player] then
	    gods[player] = nil
	    vRPclient.notify(player,lang.godmode.off())
	  else
	    gods[player] = user_id
	    vRPclient.notify(player,lang.godmode.on())
	  end
    end
  end)
end, lang.godmode.desc()}

-- spawn vehicle
local ch_spawnveh = {function(player,choice) 
  Citizen.CreateThread(function() 
	vRP.prompt(player,lang.spawnveh.prompt(),"",function(player,model)
	  if model ~= nil and model ~= "" then 
	    BMclient.spawnVehicle(player,model)
	  else
		vRPclient.notify(player,lang.common.invalid_value())
	  end
	end)
  end)
end,lang.spawnveh.desc()}