local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

dofile(modpath .. "/commands.lua")

-- reset = true

local players = {}

minetest.register_craftitem(modname .. ":dungeon_wand", {
	description = "Dungeon Wand",
	inventory_image = "dungeon_wand.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local name = placer:get_player_name()
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



minetest.register_node("dungeon:stone_brick", {
	description = "Stone bricks",
	tiles = {{name = "dungeon_stone_brick_4x4.png", align_style = "world", scale = 4}},
	groups = {},
})

minetest.register_node("dungeon:stone_block", {
	description = "Stone Blocks",
	tiles = {{name = "dungeon_stone_block_4x4.png", align_style = "world", scale = 4}},
	groups = {},
})

minetest.register_node("dungeon:floor", {
	description = "Dungeon Floor (rename me)",
	tiles = {{name = "dungeon_floor_4x4.png", align_style = "world", scale = 4}},
	groups = {},
})

minetest.register_node("dungeon:planks", {
	description = "Dungeon planks (rename me)",
	tiles = {{name = "dungeon_planks_4x4.png", align_style = "world", scale = 4}},
	groups = {},
})

minetest.register_node("dungeon:gate_closed", {
	description = "Closed Gate",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"dungeon_gate_top.png", "dungeon_gate_top.png", "dungeon_gate_top.png^[transformR90", "dungeon_gate_top.png^[transformR90", "dungeon_gate.png", "dungeon_gate.png"},
	use_texture_alpha = "clip",
	groups = {},
	visual_scale = 3,
	node_box = {
        type = "fixed",
        fixed = {
			{-0.5, -0.5, -1/16, -2/16, 0.5, 1/16},
			{2/16, -0.5, -1/16, 0.5, 0.5, 1/16},

			{-2/16, -0.5, -1/16, 2/16, -2/16, 1/16},
			{-2/16, 2/16, -1/16, 2/16, 0.5, 1/16},

			{-2/16, -2/16, 0, 2/16, 2/16, 0},
		}
    },
	collision_box = {
        type = "fixed",
        fixed = {-1.5, -1.5, -3/16, 1.5, 1.5, 3/16}
    },
	selection_box = {
        type = "fixed",
        fixed = {-1.5, -1.5, -3/16, 1.5, 1.5, 3/16}
    },
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.swap_node(pos, {name = "dungeon:gate_open", param2 = node.param2})
	end,
})

minetest.register_node("dungeon:gate_open", {
	description = "Open Gate",
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	tiles = {"dungeon_gate_top.png", "dungeon_gate_top.png", "dungeon_gate_top.png^[transformR90", "dungeon_gate_top.png^[transformR90",
			"[combine:48x48:0,-40=dungeon_gate.png", "[combine:48x48:0,-40=dungeon_gate.png"},
	use_texture_alpha = "opaque",
	groups = {},
	visual_scale = 3,
	node_box = {
        type = "fixed",
        fixed = {-0.5, 1/3, -1/16, 0.5, 0.5, 1/16}
    },
	collision_box = {
        type = "fixed",
        fixed = {-1.5, 1, -3/16, 1.5, 1.5, 3/16}
    },
	selection_box = {
        type = "fixed",
        fixed = {-1.5, 1, -3/16, 1.5, 1.5, 3/16}
    },
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		minetest.swap_node(pos, {name = "dungeon:gate_closed", param2 = node.param2})
	end,
})

minetest.register_node("dungeon:item_spawner", {
	description = "Item Spawner",
	tiles = {"dungeon_item_spawner.png"},
	groups = {},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
    	inv:set_size("main", 1)
		meta:set_string("formspec",
            "formspec_version[4]"..
            "size[10.25,6.75]"..
            "container[0.25,0.25]" ..
            "list[context;main;4.375,0;1,1;]"..
            "list[current_player;main;0,1.5;8,4;]"..
			"button[6,0.25;2.25,0.5;reset;Reset]" ..
            "container_end[]"..
			"listring[]")
	end,

	on_receive_fields = function(pos, formname, fields, sender)
		if fields.reset then
			minetest.get_meta(pos):set_string("taken", "")
			minetest.chat_send_all(formname .. "foo")
		end
	end,

	_on_lbm = function(pos, node)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()

		if reset then meta:set_string("taken", "") end

		if inv:is_empty("main") or meta:get_string("taken") == "true" then return end

		local item = inv:get_stack("main", 1)
		local stack = minetest.spawn_item({x = pos.x, y = pos.y + 2, z = pos.z}, item)

		stack:set_properties({static_save = false})
		stack = stack:get_luaentity()
		stack.pos = pos
		local of = stack.on_punch
		stack.on_punch = function(self, hitter)
			local meta = minetest.get_meta(pos)
			meta:set_string("taken", "true")
			of(self, hitter)
		end

	end,
})

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if def._on_lbm then
			local groups = table.copy(def.groups)
			groups["_on_lbm"] = 1
			minetest.override_item(name,{
				groups = groups,
			})
		end
	end
end)

minetest.register_lbm({
        label = "run '_on_lbm' for nodes which register it",
        name = "dungeon:_on_lbm",
        nodenames = {"group:_on_lbm"},
        run_at_every_load = true,
        action = function(pos, node)
			minetest.registered_nodes[node.name]._on_lbm(pos, node)
		end,
    })
