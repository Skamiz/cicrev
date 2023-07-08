

-- WALLS
--------------------------------------------------------------------------------

local wall_prototype = {
	description = "nameless wall",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {},
	drawtype = "nodebox",
	connects_to = {"group:xjoined", "group:solid_node"},
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

function xjoined.register_wall(name, def)
	-- wall with post
	for k, v in pairs(wall_prototype) do
		if def[k] == nil then
			-- if type(v) == "table" then v = table.copy(v)
			def[k] = v
		end
	end
	def.groups.xjoined = 1
	def.groups.wall = 1
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
	local def_np = table.copy(def)
	def_np.description = def.description .. " (no post)"
	def_np.drop = name
	def_np.groups.not_in_creative_inventory = 1
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
	local def_t = table.copy(def_np)
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
	local def_t_np = table.copy(def_t)
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

function xjoined.register_wall_recipe(output, input)
	minetest.register_craft({
		output = output,
		recipe = {
            {"", input, ""},
            {input, input, input},
            {input, input, input},
        },
	})
end


-- FENCES
--------------------------------------------------------------------------------

local fence_prototype = {
	description = "nameless fence",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {},
	drawtype = "nodebox",
	connects_to = {"group:xjoined", "group:solid_node"},
	node_box = {
		type = "connected",
		connect_sides = {"top", "bottom", "front", "left", "back", "right"},
		fixed = {-2/16, -8/16, -2/16, 2/16, 8/16, 2/16},
		connect_front = {
			{ -1/16, -6/16, -8/16,  1/16, -2/16, -2/16},
			{ -1/16,  2/16, -8/16,  1/16,  6/16, -2/16},
			-- {  1/16, -8/16,  4/16,  2/16,  7/16,  7/16},
		},
        connect_left = {
			{ -8/16, -6/16, -1/16, -2/16, -2/16,  1/16},
			{ -8/16,  2/16, -1/16, -2/16,  6/16,  1/16},
		},
        connect_back = {
			{ -1/16, -6/16,  2/16,  1/16, -2/16,  8/16},
			{ -1/16,  2/16,  2/16,  1/16,  6/16,  8/16},
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

function xjoined.register_fence(name, def)
	for k, v in pairs(fence_prototype) do
		if def[k] == nil then
			-- if type(v) == "table" then v = teble.copy(v)
			def[k] = v
		end
	end
	def.groups.xjoined = 1
	def.groups.fence = 1
	def.on_punch = function(pos, node, puncher, pointed_thing)
		if puncher:get_wielded_item():get_name() == name then
			minetest.set_node(pos, {name = name .. "_nopost"})
		else
			minetest.node_punch(pos, node, puncher, pointed_thing)
		end
	end

	local def_np = table.copy(def)

	minetest.register_node(name, def)

	def_np.drop = name
	def_np.groups.not_in_creative_inventory = 1
	def_np.node_box = nodebox_fence_nopost
	def_np.on_punch = function(pos, node, puncher, pointed_thing)
		if puncher:get_wielded_item():get_name() == name then
			minetest.set_node(pos, {name = name})
		else
			minetest.node_punch(pos, node, puncher, pointed_thing)
		end
	end
	minetest.register_node(name .. "_nopost", def_np)
end


-- PANES
--------------------------------------------------------------------------------

local pane_prototype = {
	description = "nameless pane",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {},
	drawtype = "nodebox",
	connects_to = {"group:xjoined", "group:solid_node"},
	node_box = {
		type = "connected",
		fixed = {-1/16, -8/16, -1/16, 1/16, 8/16, 1/16},
		connect_front = {-1/16, -8/16, -8/16, 1/16, 8/16, -1/16},
        connect_left = {-8/16, -8/16, -1/16, -1/16, 8/16, 1/16},
        connect_back = {-1/16, -8/16, 1/16, 1/16, 8/16, 8/16},
        connect_right = {1/16, -8/16, -1/16, 8/16, 8/16, 1/16},
	}
}

function xjoined.register_pane(name, def)
	for k, v in pairs(pane_prototype) do
		if def[k] == nil then
			def[k] = v
		end
	end
	def.groups.xjoined = 1
	def.groups.pane = 1
	minetest.register_node(name, def)
end

function xjoined.register_pane_recipe(output, input)
	minetest.register_craft({
		output = output,
		recipe = {
            {input, input, input},
            {input, input, input},
        },
	})
end


-- connect to all full nodes
--------------------------------------------------------------------------------

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if def.drawtype == "normal" and def.walkable then
			local groups = table.copy(def.groups)
			groups["solid_node"] = 1
			minetest.override_item(name,{
				groups = groups,
			})
		end
	end
end)
