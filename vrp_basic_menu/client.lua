--bind client tunnel interface
vRPbm = {}
Tunnel.bindInterface("vRP_basic_menu",vRPbm)
vRP = Proxy.getInterface("vRP")

local frozen = false
local unfrozen = false
function vRPbm.loadFreeze(freeze)
	if freeze then
	  frozen = true
	  unfrozen = false
	else
	  unfrozen = true
	end
end

function vRPbm.getArmour()
  return GetPedArmour(GetPlayerPed(-1))
end

function vRPbm.getNearestVehicle(radius)
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
  local ped = GetPlayerPed(-1)
  if IsPedSittingInAnyVehicle(ped) then
    return GetVehiclePedIsIn(ped, true)
  else
    -- flags used:
    --- 8192: boat
    --- 4096: helicos
    --- 4,2,1: cars (with police)

    local veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+5.0001, 0, 8192+4096+4+2+1)  -- boats, helicos
    if not IsEntityAVehicle(veh) then veh = GetClosestVehicle(x+0.0001,y+0.0001,z+0.0001, radius+5.0001, 0, 4+2+1) end -- cars
    return veh
  end
end

function vRPbm.deleteNearestVehicle(radius)
  local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(-1),true))
  local veh = vRPbm.getNearestVehicle(radius)
  
  if IsEntityAVehicle(veh) then
    SetVehicleHasBeenOwnedByPlayer(veh,false)
    Citizen.InvokeNative(0xAD738C3085FE7E11, veh, false, true) -- set not as mission entity
    SetVehicleAsNoLongerNeeded(Citizen.PointerValueIntInitialized(veh))
    Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(veh))
    vRP.notify({"~g~Vehicle deleted."})
  else
    vRP.notify({"~r~Too far away from vehicle."})
  end
end

function vRPbm.setArmour(armour,vest)
  local player = GetPlayerPed(-1)
  if vest then
	if(GetEntityModel(player) == GetHashKey("mp_m_freemode_01")) then
	  SetPedComponentVariation(player, 9, 4, 1, 2)  --Bulletproof Vest
	else 
	  if(GetEntityModel(player) == GetHashKey("mp_f_freemode_01")) then
	    SetPedComponentVariation(player, 9, 6, 1, 2)
	  end
	end
  end
  local n = math.floor(armour)
  SetPedArmour(player,n)
end

local state_ready = false

AddEventHandler("playerSpawned",function() -- delay state recording
  state_ready = false
  
  Citizen.CreateThread(function()
    Citizen.Wait(30000)
    state_ready = true
  end)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(30000)

    if IsPlayerPlaying(PlayerId()) and state_ready then
	  if vRPbm.getArmour() == 0 then
	    if(GetEntityModel(GetPlayerPed(-1)) == GetHashKey("mp_m_freemode_01")) or (GetEntityModel(GetPlayerPed(-1)) == GetHashKey("mp_f_freemode_01")) then
	      SetPedComponentVariation(GetPlayerPed(-1), 9, 0, 1, 2)
		end
	  end
    end
  end
end)

Citizen.CreateThread(function()
	while true do
		if frozen then
			if unfrozen then
				SetEntityInvincible(GetPlayerPed(-1),false)
				SetEntityVisible(GetPlayerPed(-1),true)
				FreezeEntityPosition(GetPlayerPed(-1),false)
				frozen = false
			else
				SetEntityInvincible(GetPlayerPed(-1),true)
				SetEntityVisible(GetPlayerPed(-1),false)
				FreezeEntityPosition(GetPlayerPed(-1),true)
			end
		end
		Citizen.Wait(0)
	end
end)
