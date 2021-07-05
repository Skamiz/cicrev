local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- dofile(modpath .. "/other_file.lua")

local players = {}

minetest.register_craftitem(modname .. ":time_wand", {
	description = "Dungeon Wand",
	inventory_image = "dungeon_wand.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local meta = itemstack:get_meta()
		local tmeta = meta:to_table()
		-- print(dump(tmeta))
		for k, v in pairs(tmeta.fields) do
			minetest.chat_send_all(type(k) .. "|" .. k .. "|" .. type(v) .. "|" .. v)
		end
	end,
	on_use = function(itemstack, user, pointed_thing)
		local meta = itemstack:get_meta()
		local pos = user:get_pos()

		pos.x = pos.x + 0.5
		pos.y = pos.y + 0.5
		pos.z = pos.z + 0.5
		pos.x = pos.x - pos.x%3
		pos.y = pos.y - pos.y%3
		pos.z = pos.z - pos.z%3

		for i = 1, 5 do
			if meta:contains("layer" .. i) then
				local node = meta:get_string("layer" .. i)
				if minetest.registered_craftitems[node] then node = "air" end
				-- minetest.chat_send_all("Node is: '" .. node .. "'")
				for j = 0, 2 do
					for k = 0, 2 do
						-- minetest.chat_send_all("setting node: " .. node)
						minetest.set_node({x = pos.x + j, y = (pos.y-2) + i, z = pos.z + k}, {name = node})
					end
				end
			end
		end
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		local name = user:get_player_name()
		if not players[name] then
			players[name] = minetest.create_detached_inventory(modname .. ":" .. name .. "_inventory", callbacks)
			players[name]:set_size("main", 5)
		end

		local meta = itemstack:get_meta()

		for i = 1, 5 do
			players[name]:set_stack("main", i, meta:get_string("layer" .. i))
		end

		minetest.show_formspec(name, modname .. ":wand_config",
			"formspec_version[4]" ..
			"size[10.75,8.5]"..
			"container[0.5,0.5]"..
			"list[detached:" .. modname .. ":" .. name .. "_inventory" .. ";main;0,0;8,2;]" ..
			"list[current_player;main;0,2.75;8,4;]" ..
			"listring[]" ..
			"container_end[]" ..
			""
		)
	end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= modname .. ":wand_config" then return false end

	local name = player:get_player_name()

	local item = player:get_wielded_item()
	local meta = item:get_meta()
	for i = 1, 5 do
		meta:set_string("layer" .. i, players[name]:get_stack("main", i):get_name())
	end
	player:set_wielded_item(item)
end)
