function vRPbm.chargePhoneNumber(user_id,phone)
Citizen.CreateThread(function()
  local player = vRP.getUserSource(user_id)
  local directory_name = vRP.getPhoneDirectoryName(user_id, phone)
  if directory_name == "unknown" then
	directory_name = phone
  end
  vRP.prompt(player,lang.mcharge.prompt({directory_name}),"",function(player,charge)
	if charge ~= nil and charge ~= "" and tonumber(charge)>0 then 
	  local target_id = vRP.getUserByPhone(phone)
		if target_id~=nil then
			if charge ~= nil and charge ~= "" then 
	          local target = vRP.getUserSource(target_id)
			  if target ~= nil then
				local identity = vRP.getUserIdentity(user_id)
				  local my_directory_name = vRP.getPhoneDirectoryName(target_id, identity.phone)
				  if my_directory_name == "unknown" then
				    my_directory_name = identity.phone
				  end
				  vRP.request(target,lang.mcharge.request({my_directory_name,charge}),600,function(req_player,ok)
				    if ok then
					  local target_bank = vRP.getBankMoney(target_id) - tonumber(charge)
					  local my_bank = vRP.getBankMoney(user_id) + tonumber(charge)
		              if target_bank>0 then
					    vRP.setBankMoney(user_id,my_bank)
					    vRP.setBankMoney(target_id,target_bank)
					    vRPclient.notify(player,lang.mcharge.charger({charge,directory_name}))
						vRPclient.notify(target,lang.mcharge.charged({my_directory_name,charge}))
					    --vRPbm.logInfoToFile(lang.mcharge.file(),lang.mcharge.log({user_id,target_id,charge,my_bank,target_bank})
					    vRP.closeMenu(player)
                      else
                        vRPclient.notify(target,lang.money.not_enough())
                        vRPclient.notify(player,lang.mcharge.not_enough({directory_name}))
                      end
				    else
                      vRPclient.notify(player,lang.mcharge.refused({directory_name}))
				    end
				  end)
			  else
				vRPclient.notify(player,lang.common.invalid_value())
			  end
			else
			  vRPclient.notify(player,lang.common.invalid_value())
			end
		else
          vRPclient.notify(player,lang.common.invalid_value())
		end
	else
      vRPclient.notify(player,lang.common.invalid_value())
	end
  end)
end)
end

function vRPbm.payPhoneNumber(user_id,phone)
Citizen.CreateThread(function()
  local player = vRP.getUserSource(user_id)
  local directory_name = vRP.getPhoneDirectoryName(user_id, phone)
  if directory_name == "unknown" then
	directory_name = phone
  end
  vRP.prompt(player,lang.mpay.prompt({directory_name}),"",function(player,transfer)
	if transfer ~= nil and transfer ~= "" and tonumber(transfer)>0 then 
	  local target_id = vRP.getUserByPhone(phone)
	    local my_bank = vRP.getBankMoney(user_id) - tonumber(transfer)
		if target_id~=nil then
          if my_bank >= 0 then
		    local target = vRP.getUserSource(target_id)
			if target ~= nil then
			  vRP.setBankMoney(user_id,my_bank)
              vRPclient.notify(player,lang.mpay.transfer({transfer,directory_name}))
			  local target_bank = vRP.getBankMoney(target_id) + tonumber(transfer)
			  vRP.setBankMoney(target_id,target_bank)
			  --vRPbm.logInfoToFile(lang.mpay.file(),lang.mpay.log({user_id,target_id,transfer,my_bank,target_bank})
			  local identity = vRP.getUserIdentity(user_id)
		        local my_directory_name = vRP.getPhoneDirectoryName(target_id, identity.phone)
			    if my_directory_name == "unknown" then
		          my_directory_name = identity.phone
			    end
                vRPclient.notify(target,lang.mpay.receive({transfer,my_directory_name}))
              vRP.closeMenu(player)
			else
			  vRPclient.notify(player,lang.common.invalid_value())
			end
          else
            vRPclient.notify(player,lang.money.not_enough())
          end
		else
		  vRPclient.notify(player,lang.common.invalid_value())
		end
	else
	  vRPclient.notify(player,lang.common.invalid_value())
	end
  end)
end)
end