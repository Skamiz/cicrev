minetest.register_craftitem("cicrev:stick", {
	description = "Stick",
	inventory_image = "cicrev_stick.png",
	groups = {stick = 1, tool_handle = 1},
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.get_node(pointed_thing.under).name == "cicrev:campfire_lit" then
			itemstack:take_item()
			local leftover = placer:get_inventory():add_item("main", "cicrev:torch")
			if not leftover:is_empty() then
				minetest.add_item(placer:get_pos(), "cicrev:torch")
			end
			return itemstack
		end
	end,
})
minetest.register_craftitem("cicrev:flint", {
	description = "Flint stone",
	inventory_image = "cicrev_flint.png",
})
minetest.register_craftitem("cicrev:axe_head_flint", {
	description = "Axe head (flint)",
	inventory_image = "cicrev_axe_head_flint.png",
})
minetest.register_craftitem("cicrev:knife_head_flint", {
	description = "Knife head (flint)",
	inventory_image = "cicrev_knife_head_flint.png",
})
minetest.register_craftitem("cicrev:grass", {
	description = "Grass bundle",
	inventory_image = "cicrev_grass.png",
})
minetest.register_craftitem("cicrev:grass_rope", {
	description = "Grass Rope",
	inventory_image = "cicrev_grass_rope.png",
})
minetest.register_craftitem("cicrev:brick", {
	description = "Brick",
	inventory_image = "cicrev_brick.png",
})
minetest.register_craftitem("cicrev:ingot_copper", {
	description = "Copper Cube",
	inventory_image = "cicrev_ingot_copper.png",
})
minetest.register_craftitem("cicrev:clay_lump", {
	description = "Wet Lump of Clay",
	inventory_image = "cicrev_clay_lump.png",
	on_place = function(itemstack, placer, pointed_thing)
		if minetest.get_node(pointed_thing.under).name ~= "cicrev:brick_mold" or placer:get_player_control().sneak then
			return
		end
		minetest.set_node(pointed_thing.under, {name = "cicrev:brick_mold_full"})
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craftitem("cicrev:rune_speed", {
	description = "Speed",
	inventory_image = "cicrev_rune_speed.png",
	on_secondary_use = function(itemstack, user, pointed_thing)
		player_effects.add_effect(user, {
			source = "rune",
			effect_name = "speed",
			-- text_influence = "function (s) return s + 0.3 end",
			text_influence = "function (s) return s + 0.5 end",
			timeout = 30,
			priority = 80,
			persistant = true,
		})
		itemstack:take_item()
		return itemstack
	end,
})



minetest.register_craftitem("cicrev:coal", {
	description = "Coal",
	inventory_image = "cicrev_coal.png",
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then return end
		local node = minetest.get_node(pointed_thing.under)
		local node_def = minetest.registered_nodes[node.name]
		-- minetest.chat_send_all(node_def.drawtype)
		if node_def.drawtype ~= "normal" then return end
		local pos = pointed_thing.above
		local param2 = cicrev.get_arrow_rotation(user, pointed_thing)

		minetest.set_node(pos, {name = "cicrev:coal_arrow", param2 = param2})
	end
})


minetest.register_craftitem("cicrev:time_wand", {
	description = "Wand of time",
	inventory_image = "cicrev_time_wand.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.under
		local timer = minetest.get_node_timer(pos)
		timer:set(1, 0)
	end,
	on_use = function(itemstack, user, pointed_thing)
		minetest.chat_send_all("Setting time to morining.")
		minetest.set_timeofday(0.25)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		minetest.chat_send_all("Setting time to midnight.")
		minetest.set_timeofday(0)
	end
})

minetest.register_craftitem("cicrev:wrench", {
	description = "Wrench",
	inventory_image = "cicrev_wrench.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if not placer:get_player_control().sneak then
			node.param2 = node.param2 + 4
		else
			node.param2 = node.param2 - 4
		end
		minetest.swap_node(pos, node)
	end,
	on_use = function(itemstack, user, pointed_thing)
		if not pointed_thing.under then return end
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if not user:get_player_control().sneak then
			node.param2 = node.param2 + 1
		else
			node.param2 = node.param2 - 1
		end
		minetest.swap_node(pos, node)
	end,
})
