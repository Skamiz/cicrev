local shape_name = "fence"

local prototype = {
	description = "nameless " .. shape_name,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {},
	drawtype = "nodebox",
	connects_to = {"group:solid_node", "group:connected_barrier", "group:" .. shape_name},
	node_box = {
		type = "connected",
		-- connect_sides = {"top", "bottom", "front", "left", "back", "right"},
		fixed = {-2/16, -8/16, -2/16, 2/16, 8/16, 2/16},
		connect_front = {
			{ -1/16, -6/16, -8/16,  1/16, -2/16, -2/16},
			{ -1/16,  2/16, -8/16,  1/16,  6/16, -2/16},
		},
        connect_left = {
			{ -8/16, -6/16, -1/16, -2/16, -2/16,  1/16},
			{ -8/16,  2/16, -1/16, -2/16,  6/16,  1/16},
		},
        connect_back = {
			{ -1/16, -6/16,  2/16,  1/16, -2/16,  8/16},
			{ -1/16,  2/16,  2/16,  1/16,  6/16,  8/16},
			-- {  1/16, -7/16,  4/16,  2/16,  7/16,  7/16},
		},
        connect_right = {
			{  2/16, -6/16, -1/16,  8/16, -2/16,  1/16},
			{  2/16,  2/16, -1/16,  8/16,  6/16,  1/16},
		},
	}
}

local nodebox_fence_nopost = {
	type = "connected",
	fixed = {
		{-1/16, -6/16, -1/16, 1/16, -2/16, 1/16},
		{-1/16, 2/16, -1/16, 1/16, 6/16, 1/16},
	},
	connect_front = {
		{-1/16, -6/16, -8/16, 1/16, -2/16, -1/16},
		{-1/16, 2/16, -8/16, 1/16, 6/16, -1/16},
	},
	connect_left = {
		{-8/16, -6/16, -1/16, -1/16, -2/16, 1/16},
		{-8/16, 2/16, -1/16, -1/16, 6/16, 1/16},
	},
	connect_back = {
		{-1/16, -6/16, 1/16, 1/16, -2/16, 8/16},
		{-1/16, 2/16, 1/16, 1/16, 6/16, 8/16},
	},
	connect_right = {
		{1/16, -6/16, -1/16, 8/16, -2/16, 1/16},
		{1/16, 2/16, -1/16, 8/16, 6/16, 1/16},
	},
}

shapes.register[shape_name] = function(name, def)
	for property, value in pairs(prototype) do
		if def[property] == nil then
			def[property] = value
		end
	end
	shapes.add_group(def, "shape", 1)
	shapes.add_group(def, "connected_barrier", 1)
	shapes.add_group(def, shape_name, 1)

	local def_np = table.copy(def)

	def.on_punch = function(pos, node, puncher, pointed_thing)
		if puncher:get_wielded_item():get_name() == name then
			minetest.set_node(pos, {name = name .. "_nopost"})
		else
			minetest.node_punch(pos, node, puncher, pointed_thing)
		end
	end

	shapes.add_group(def_np, "not_in_creative_inventory", 1)
	def_np.drop = name
	def_np.node_box = nodebox_fence_nopost
	def_np.on_punch = function(pos, node, puncher, pointed_thing)
		if puncher:get_wielded_item():get_name() == name then
			minetest.set_node(pos, {name = name})
		else
			minetest.node_punch(pos, node, puncher, pointed_thing)
		end
	end

	minetest.register_node(name, def)
	minetest.register_node(name .. "_nopost", def_np)
end
