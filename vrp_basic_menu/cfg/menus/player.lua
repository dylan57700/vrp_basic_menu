ch_player_menu = {function(player,choice)
	local user_id = vRP.getUserId(player)
	local menu = {}
	menu.name = lang.player.menu.title()
	menu.css = {top = "75px", header_color = "rgba(0,0,255,0.75)"}
    menu.onclose = function(player) vRP.openMainMenu(player) end -- nest menu
	
    if vRP.hasPermission(user_id,lang.store.money.perm()) then
      menu[lang.store.money.button()] = choice_store_money -- transforms money in wallet to money in inventory to be stored in houses and cars
    end
	
    if vRP.hasPermission(user_id,lang.fixhaircut.perm()) then
      menu[lang.fixhaircut.button()] = ch_fixhair -- just a work around for barbershop green hair bug while I am busy
    end
	
    if vRP.hasPermission(user_id,lang.userlist.perm()) then
      menu[lang.userlist.button()] = ch_userlist -- a user list for players with vRP ids, player name and identity names only.
    end
	
    if vRP.hasPermission(user_id,lang.store.weapons.perm()) then
      menu[lang.store.weapons.button()] = choice_store_weapons -- store player weapons, like police store weapons from vrp
    end
	
    if vRP.hasPermission(user_id,lang.store.bodyarmor.perm()) then
      menu[lang.store.bodyarmor.button()] = choice_store_armor -- store player armor
    end
	
    if vRP.hasPermission(user_id,lang.inspect.perm()) then
      menu[lang.inspect.button()] = choice_player_check -- checks nearest player inventory, like police check from vrp
    end
	
	vRP.openMenu(player, menu)
end, lang.player.menu.desc()}