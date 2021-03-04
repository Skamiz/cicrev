local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

--[[
tool wear
code cleanup

Stretch goals:
make the objects rotate to the nodes rotation to stop jaring transition between node and object
	- 6 of 24 positions are unreachable due to gimbal lock
	- actually rotating attached objects is impossible
--]]



falling_trees = {}


local scale = (2/3) -- visual = "item", have weired default scaling
local max_logs = 50 --to preven chopping whole forests at once
local leave_search_distance = 3 --how far from each log to look for leaves
local pivot_texture = "invisible.png" -- used for the pivoting object

-- for the rotation of param2 nodes
local x_rot = {[0] = 12,
	13, 14, 15, 7, 4, 5, 6, 9,
	10, 11, 8, 20, 21, 22, 23, 0,
	1, 2, 3, 16, 17, 18, 19, 12,
}
local z_rot = {[0] = 4,
	5, 6, 7, 22, 23, 20, 21, 0,
	1, 2, 3, 13, 14, 15, 12, 19,
	16, 17, 18, 10, 11, 8, 9, 4,
}

local trees = {}

-- It is assumed that each log can belong only to one tree


-- breadth first algorythm which seeks logs upwards and to the sides
-- could be limmited to a cone expanding upwards from the starting point to prevent absurd 'tree' felling
local function detect_logs(o_pos, log_nodes)
	local logs = {}
	local queue = {o_pos}

	while queue[1] and #logs < max_logs do
		logs[minetest.hash_node_position(queue[1])] = minetest.get_node(queue[1])

		local potential_pos = minetest.find_nodes_in_area(
				vector.add(queue[1], {x=-1,y=0,z=-1}), vector.add(queue[1], 1), log_nodes)
		for _, pos in pairs(potential_pos) do
			if (not logs[minetest.hash_node_position(pos)]) and
					(math.abs(pos.x-o_pos.x)<=(pos.y-o_pos.y)) and
					(math.abs(pos.z-o_pos.z)<=(pos.y-o_pos.y)) then
				table.insert(queue, pos)
			end
		end

		for k, v in ipairs(queue) do
			queue[k] = queue[k + 1]
		end
	end
	return logs
end
-- Get squared distance
local function get_distance_2(pos_1, pos_2)
	return 	(pos_1.x - pos_2.x) * (pos_1.x - pos_2.x) +
	 		(pos_1.y - pos_2.y) * (pos_1.y - pos_2.y) +
	 		(pos_1.z - pos_2.z) * (pos_1.z - pos_2.z)
end

-- for each log position search suroundings for leaves
-- this could be edited in conjunction with cicrev to only take leaves which depend on this tree
local function detect_leaves(logs, leave_nodes, log_nodes)
	local leaves = {}

	for pos_hash, _ in pairs(logs) do
		local l_pos = minetest.get_position_from_hash(pos_hash)
		local leave_position = minetest.find_nodes_in_area(
				vector.add(l_pos, -leave_search_distance), vector.add(l_pos, leave_search_distance), leave_nodes)
		for _, pos in pairs(leave_position) do
			local hash = minetest.hash_node_position(pos)
			leaves[hash] = leaves[hash] or minetest.get_node(pos)
		end
	end

	-- fpr each leave find the nearest log
	for pos_hash, node in pairs(leaves) do
		local l_pos = minetest.get_position_from_hash(pos_hash)
		local nearby_logs = minetest.find_nodes_in_area(
				vector.add(l_pos, -leave_search_distance), vector.add(l_pos, leave_search_distance), log_nodes)
		local nearest_log = nearby_logs[1]
		local shortest_distance = get_distance_2(nearest_log, l_pos)
		for i, log_pos in ipairs(nearby_logs) do
			local distance = get_distance_2(log_pos, l_pos)
			-- for one the log must be nearer, for the other it must be part of the current tree
			if distance < shortest_distance and logs[minetest.hash_node_position(log_pos)] then
				nearest_log = log_pos
				shortest_distance = distance
			end
		end

		-- remember nearest log and relative distance to it
		node.nearest_log = logs[minetest.hash_node_position(nearest_log)]
		local d_log_pos = {x = l_pos.x-nearest_log.x, y = l_pos.y-nearest_log.y, z = l_pos.z-nearest_log.z}
		node.d_log_pos = d_log_pos
	end

	return leaves
end

local function detect_tree(pos, log_nodes, leave_nodes)
	local tree = {}
	tree.pivot = pos
	tree.logs = detect_logs(tree.pivot, log_nodes)
	tree.leaves = detect_leaves(tree.logs, leave_nodes, log_nodes)

	return tree
end

--[[
-- There was a whole section here which rotated ojects simulating paramtype2 = "facedir"
-- to the apropriate rotation so the transition between node and object is even smoother.
-- Turns out it is impossible to aply rotation to attached objects.

local function rotate_to_param2(object, param2)
	local rotation = param2 % 4
	local direction = (param2 - rotation) / 4

	local rot = object:get_rotation()
	-- rot.x = rot.x + ((math.pi / 2))
	-- rot.y = rot.y + ((math.pi / 2))
	-- rot.z = rot.z + ((math.pi / 2))

	if direction == 0 then
		rot.y = rot.y - (rotation * (math.pi / 2))
	elseif direction == 5 then
		rot.z = rot.z + math.pi
		rot.y = rot.y + (rotation * (math.pi / 2))
	elseif direction == 3 then
		rot.z = rot.z + (math.pi / 2)
		rot.x = rot.x + (rotation * (math.pi / 2))
	elseif direction == 4 then
		rot.z = rot.z - (math.pi / 2)
		rot.x = rot.x - (rotation * (math.pi / 2))

	-- In theses cases we give up on rotation since gimbal lock makes that impossible
	elseif direction == 1 then
		rot.x = rot.x + (math.pi / 2)

	elseif direction == 2 then
		rot.x = rot.x - (math.pi / 2)

	end
	object:set_rotation(rot)
end
--]]


local function add_children(pivot, nodes)
	local pivot_pos = pivot:get_pos()
	for pos_hash, node in pairs(nodes) do
		local pos = minetest.get_position_from_hash(pos_hash)
		local d_pos = {x = pos.x-pivot_pos.x, y = pos.y-pivot_pos.y, z = pos.z-pivot_pos.z}
		node.d_pos = d_pos
		minetest.remove_node(pos)
		local node_obj = minetest.add_entity(pivot_pos, modname .. ":node_object")
		node_obj:set_attach(pivot, "", vector.multiply(d_pos, 10))
		node_obj:set_properties({wield_item = node.name})

		--[[
		-- Part of the code trying to rotate attached objects.
		if minetest.registered_nodes[node.name].paramtype2 == "facedir" then
			rotate_to_param2(node_obj, node.param2)
		end
		--]]
	end
end

local function create_tree_object(tree, fall_direction)
	local pivot_pos = tree.pivot
	local pivot = minetest.add_entity(pivot_pos, modname .. ":pivot_object")
	pivot:set_acceleration({x=0, y=-9.81, z=0})
	local luaent = pivot:get_luaentity()
	luaent._dir = fall_direction
	luaent._tree = tree

	add_children(pivot, tree.logs)
	add_children(pivot, tree.leaves)
end

local function is_buildable_to(pos)
	return minetest.registered_nodes[minetest.get_node(pos).name].buildable_to
end

-- Takes the param2 of a "facedir" node and turns it
local function get_rotated_param2(param2, dir)
	if dir.x > 0 then
		param2 = x_rot[param2]
	elseif dir.x < 0 then
		param2 = x_rot[param2]
		param2 = x_rot[param2]
		param2 = x_rot[param2]
	elseif dir.z > 0 then
		param2 = z_rot[param2]
	elseif dir.z < 0 then
		param2 = z_rot[param2]
		param2 = z_rot[param2]
		param2 = z_rot[param2]
	end

	return param2
end

local function place_tree(pivot)
	local tree = pivot._tree
	local o_pos = pivot.object:get_pos()
	local dir = pivot._dir

	for pos_hash, node in pairs(tree.logs) do
		local pos = minetest.get_position_from_hash(pos_hash)
		local d_pos = node.d_pos

		if minetest.registered_nodes[node.name].paramtype2 == "facedir" then
			node.param2 = get_rotated_param2(node.param2, dir)
		end

		local new_d_pos = {
			x = (d_pos.x * math.abs(dir.z)) + (d_pos.y * dir.x),
			y = (d_pos.z * -dir.z) + (d_pos.x * -dir.x),
			z = (d_pos.y * dir.z) + (d_pos.z * math.abs(dir.x)),
		}

		local new_pos = vector.add(o_pos, new_d_pos)

		if is_buildable_to(new_pos) then
			local n = 0
			while is_buildable_to(new_pos) and n < 50 do
				new_pos.y = new_pos.y - 1
				n = n + 1
			end
			new_pos.y = new_pos.y + 1
		else
			local re_dir = vector.subtract(pos, new_pos)
			re_dir = vector.normalize(re_dir)
			re_dir = vector.multiply(re_dir, 0.5)
			local n = 0
			while not is_buildable_to(vector.round(new_pos)) and n < 50 do
				new_pos = vector.add(new_pos, re_dir)
				n = n + 1
			end
		end
		-- new_pos = vector.round(new_pos)
		if not is_buildable_to(new_pos) then
			local n = 0
			while not is_buildable_to(new_pos) and n < 5 do
				new_pos.y = new_pos.y + 1
				n = n + 1
			end
		end
		minetest.set_node(vector.round(new_pos), node)
		node.final_position = new_pos
	end

	for pos_hash, node in pairs(tree.leaves) do
		local pos = minetest.get_position_from_hash(pos_hash)
		local d_pos = node.d_log_pos

		local new_d_pos = {
			x = (d_pos.x * math.abs(dir.z)) + (d_pos.y * dir.x),
			y = (d_pos.z * -dir.z) + (d_pos.x * -dir.x),
			z = (d_pos.y * dir.z) + (d_pos.z * math.abs(dir.x)),
		}

		local new_pos = vector.add(node.nearest_log.final_position, new_d_pos)
		if minetest.registered_nodes[minetest.get_node(new_pos).name].buildable_to then
			minetest.set_node(new_pos, node)
		end
	end
end

local function remove_objects(object)
	for _, child in pairs(object.object:get_children()) do
		child:remove()
	end
	object.object:remove()
end

minetest.register_entity(modname .. ":pivot_object", {
	initial_properties = {
		visual = "cube",
		textures = {pivot_texture, pivot_texture, pivot_texture,
				pivot_texture, pivot_texture, pivot_texture},
		physical = true,
		static_save = false,
	},
	on_activate = function(self, staticdata, dtime_s)
		self._rotating = true
		self._falling = true
		self._falling_speed = 3
	end,

	-- TODO: break this up
	on_step = function(self, dtime, moveresult)
		local dir = self._dir

		-- check if the tree is still falling over
		if self._rotating then
			local rot = self.object:get_rotation()
			rot.x = rot.x - dir.z * ((math.pi / 2) * (dtime / self._falling_speed))
			rot.z = rot.z + dir.x * ((math.pi / 2) * (dtime / self._falling_speed))
			self.object:set_rotation(rot)
			if (math.abs(rot.x) > (math.pi / 2) or math.abs(rot.z) > (math.pi / 2)) then
				self._rotating = false
			end
		end
		-- check if the tree is still falling down
		if self._falling == true then
			local current_y = self.object:get_pos().y
			if self._last_y == current_y then
				self._falling = false
				-- self._rotating = true
				self._falling_speed = 1
			else
				self._last_y = current_y
			end
		end

		if (not self._rotating) and (not self._falling) then
			place_tree(self)
			remove_objects(self)
		end
	end,
})

minetest.register_entity(modname .. ":node_object", {
	initial_properties = {
		visual = "item",
		visual_size = {x = scale, y = scale, z = scale},
		physical = true,
		static_save = false,
		wield_item = "cicrev:tetrahedrite",
	},
	on_step = function(self, dtime, moveresult)
		local rot = self.object:get_rotation()
		-- rot.x = rot.x + ((math.pi / 2) * (dtime))
		rot.y = rot.y + ((math.pi / 2) * (dtime))
		-- rot.z = rot.z + ((math.pi / 2) * (dtime))
		self.object:set_rotation(rot)
	end,
})

function falling_trees.register_tree(tree_def)
	for _, log in pairs(tree_def.logs) do
		trees[log] = tree_def

		local old_on_dig = minetest.registered_nodes[log].on_dig or  minetest.node_dig
		minetest.override_item(log, {
			on_dig = function(pos, node, digger)
				if digger:get_player_control().sneak then
					local tree_def = detect_tree(pos, tree_def.logs, tree_def.leaves)
					create_tree_object(tree_def, minetest.facedir_to_dir(minetest.dir_to_facedir(minetest.yaw_to_dir(digger:get_look_horizontal()))))
				else
					old_on_dig(pos, node, digger)
				end
			end
		})

	end
end
