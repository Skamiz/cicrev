local modname = minetest.get_current_modname()

minetest.register_craftitem(modname .. ":fortress_wand", {
	description = "Fortress Wand",
	inventory_image = "castle_wand.png",
	wield_image = "castle_wand.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		minetest.place_schematic(pointed_thing.above, fortress_pieces.bridge)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)

	end,
	on_use = function(itemstack, user, pointed_thing)
		-- local pos = user:get_pos()
		-- local x, z = pos_to_section_pos(pos)
		-- local section_pos = {x = x, y = 0, z = z}
		-- minetest.chat_send_all("At: " .. minetest.pos_to_string(vector.round(pos)) .. " the height level is: " .. pos_to_level(pos.x, pos.y))
	end,
})


local players = {}
minetest.register_on_joinplayer(function(player)
	local player_name = player:get_player_name()
	players[player_name] = {}
	players[player_name].section_coo = player:hud_add({
		hud_elem_type = "text",
		position = {x=0, y=1},
		alignment = {x=1, y=-1},
		offset = {x=0, y=-15},
		text = "Display section coordinates here.",
	})
	players[player_name].section_pos = player:hud_add({
		hud_elem_type = "text",
		position = {x=0, y=1},
		alignment = {x=1, y=-1},
		text = "Display section position here.",
	})
end)

minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local player_name = player:get_player_name()
		local section_coo = proc_fort.get_section_coordinates(vector.add(player:get_pos(), 0.5))
		local section_pos = proc_fort.get_section_pos(vector.add(player:get_pos(), 0.5))
		player:hud_change(players[player_name].section_coo, "text", "Your, section coordinates are: " .. minetest.pos_to_string(section_coo))
		player:hud_change(players[player_name].section_pos, "text", "Your, section position is: " .. minetest.pos_to_string(section_pos))
	end
end)
