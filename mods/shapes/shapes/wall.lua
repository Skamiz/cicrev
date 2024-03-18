local shape_name = "wall"

local prototype = {
	description = "nameless " .. shape_name,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {},
	drawtype = "nodebox",
	connects_to = {"group:solid_node", "group:connected_barrier", "group:" .. shape_name},
	node_box = {
		type = "connected",
		fixed = {-4/16, -8/16, -4/16, 4/16, 8/16, 4/16},
		connect_front = {-3/16, -8/16, -8/16, 3/16, 6/16, -4/16},
        connect_left = {-8/16, -8/16, -3/16, -4/16, 6/16, 3/16},
        connect_back = {-3/16, -8/16, 4/16, 3/16, 6/16, 8/16},
        connect_right = {4/16, -8/16, -3/16, 8/16, 6/16, 3/16},
	}
}

local nodebox_wall_tall = {
	type = "connected",
	fixed = {-4/16, -8/16, -4/16, 4/16, 8/16, 4/16},
	connect_front = {-3/16, -8/16, -8/16, 3/16, 8/16, -4/16},
	connect_left = {-8/16, -8/16, -3/16, -4/16, 8/16, 3/16},
	connect_back = {-3/16, -8/16, 4/16, 3/16, 8/16, 8/16},
	connect_right = {4/16, -8/16, -3/16, 8/16, 8/16, 3/16},
}
local nodebox_wall_nopost = {
	type = "connected",
	fixed = {-3/16, -8/16, -3/16, 3/16, 6/16, 3/16},
	connect_front = {-3/16, -8/16, -8/16, 3/16, 6/16, -3/16},
	connect_left = {-8/16, -8/16, -3/16, -3/16, 6/16, 3/16},
	connect_back = {-3/16, -8/16, 3/16, 3/16, 6/16, 8/16},
	connect_right = {3/16, -8/16, -3/16, 8/16, 6/16, 3/16},
}
local nodebox_wall_tall_nopost = {
	type = "connected",
	fixed = {-3/16, -8/16, -3/16, 3/16, 8/16, 3/16},
	connect_front = {-3/16, -8/16, -8/16, 3/16, 8/16, -3/16},
	connect_left = {-8/16, -8/16, -3/16, -3/16, 8/16, 3/16},
	connect_back = {-3/16, -8/16, 3/16, 3/16, 8/16, 8/16},
	connect_right = {3/16, -8/16, -3/16, 8/16, 8/16, 3/16},
}

local function is_walkable(pos)
	local node = minetest.get_node(pos)
	return minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].walkable
end

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
	shapes.add_group(def_np, "not_in_creative_inventory", 1)
	def_np.drop = name
	local def_t = table.copy(def_np)
	local def_t_np = table.copy(def_np)

	-- wall with post
	def.on_punch = function(pos, node, puncher, pointed_thing)
		if puncher:get_wielded_item():get_name() == name then
			minetest.set_node(pos, {name = name .. "_nopost"})
		else
			minetest.node_punch(pos, node, puncher, pointed_thing)
		end
	end
	def._on_update = function(pos)
		local u_pos = vector.new(pos.x, pos.y + 1, pos.z)
		if is_walkable(u_pos) then
			minetest.set_node(pos, {name = name .. "_tall"})
		end
	end

	-- wall without post
	def_np.description = def.description .. " (no post)"
	def_np.node_box = nodebox_wall_nopost
	def_np.on_punch = function(pos, node, puncher, pointed_thing)
		if puncher:get_wielded_item():get_name() == name then
			minetest.set_node(pos, {name = name})
		else
			minetest.node_punch(pos, node, puncher, pointed_thing)
		end
	end
	def_np._on_update = function(pos)
		local u_pos = vector.new(pos.x, pos.y + 1, pos.z)
		if is_walkable(u_pos) then
			minetest.set_node(pos, {name = name .. "_tall_nopost"})
		end
	end

	-- tall wall with post
	def_t.description = def.description .. " (tall)"
	def_t.node_box = nodebox_wall_tall
	def_t.on_punch = function(pos, node, puncher, pointed_thing)
		if puncher:get_wielded_item():get_name() == name then
			minetest.set_node(pos, {name = name .. "_tall_nopost"})
		else
			minetest.node_punch(pos, node, puncher, pointed_thing)
		end
	end
	def_t._on_update = function(pos)
		local u_pos = vector.new(pos.x, pos.y + 1, pos.z)
		if not is_walkable(u_pos) then
			minetest.set_node(pos, {name = name})
		end
	end

	-- tall wall without post
	def_t_np.description = def.description .. " (tall, no post)"
	def_t_np.node_box = nodebox_wall_tall_nopost
	def_t_np.on_punch = function(pos, node, puncher, pointed_thing)
		if puncher:get_wielded_item():get_name() == name then
			minetest.set_node(pos, {name = name .. "_tall"})
		else
			minetest.node_punch(pos, node, puncher, pointed_thing)
		end
	end
	def_t_np._on_update = function(pos)
		local u_pos = vector.new(pos.x, pos.y + 1, pos.z)
		if not is_walkable(u_pos) then
			minetest.set_node(pos, {name = name .. "_nopost"})
		end
	end


	minetest.register_node(name, def)
	minetest.register_node(name .. "_nopost", def_np)
	minetest.register_node(name .. "_tall", def_t)
	minetest.register_node(name .. "_tall_nopost", def_t_np)
end
