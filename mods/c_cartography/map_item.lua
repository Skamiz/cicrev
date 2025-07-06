local cartography = cartography
minetest.register_craftitem(cartography.modname .. ":map", {
	description = table.concat({
		"Cartography Map",
		"[place] - collect map data",
		"[use] - show map",
	}, "\n"),
	inventory_image = "c_cartography_map.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		cartography.generate_data_maps()
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		user:set_physics_override({speed = 3})
	end,
	on_use = function(itemstack, user, pointed_thing)
		cartography.show_maps(user)
	end,
})
