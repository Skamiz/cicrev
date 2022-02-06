
local rotations = {
	["0"] = 0,
	["90"] = 1,
	["180"] = 2,
	["270"] = 3,
}

-- rotation of 'facedir' nodes, clockwise while looking toward -Y
local y_rot = {[0] = 1,
	2, 3, 0, 13, 14, 15, 12, 17,
	18, 19, 16, 9, 10, 11, 8, 5,
	6, 7, 4, 23, 20, 21, 22, nil,
}

-- rotates schematic by 90 `~degrees around Y axis
local function rotate_schematic(schematic)
	local size = schematic.size
	local area = VoxelArea:new({MinEdge = {x=1, y=1, z=1}, MaxEdge = size})
	new_data = {}
	for x = size.x, 1, -1 do
		for y = 1, size.y do
			for z = 1, size.z do
				local node = schematic.data[area:index(x, y, z)]
				if minetest.registered_nodes[node.name].paramtype2 == "facedir" then
					node.param2 = y_rot[node.param2]
				end
				new_data[#new_data + 1] = node
			end
		end
	end
	schematic.data = new_data
	size.x, size.z = size.z, size.x
	return schematic
end

function schem.place_tree(pos, schematic, rotation, replacements, force_placement, flags)
	if type(schematic) == "string" then
		schematic = minetest.read_schematic(schematic, {})
		if not schematic then
			return false, "Trying to place a non-existent schematic."
		end
	end
	local schematic = table.copy(schematic)

	local rot
	if not rotation then
		rot = 0
	elseif rotation == "random" then
		rot = math.random(4) - 1
	else
		rot = rotations[rotation]
	end
	for n = 1, rot do
		schematic = rotate_schematic(schematic)
	end

	replacements = replacements or {}

	if flags then
		if flags:find("place_center_x") then pos.x = pos.x - math.floor(schematic.size.x/2 - 0.5) end
		if flags:find("place_center_y") then pos.y = pos.y - math.floor(schematic.size.y/2 - 0.5) end
		if flags:find("place_center_z") then pos.z = pos.z - math.floor(schematic.size.z/2 - 0.5) end
	end

	local size = schematic.size
	local i = 1
	for z = 0, size.z - 1 do
		for y = 0, size.y - 1 do
			for x = 0, size.x - 1 do

				local node_pos = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
				local node = schematic.data[i]
				local old_node = minetest.get_node(node_pos)

				if replacements[node.name] then
					node.name = replacements[node.name]
				end

				if force_placement or node.force_place or old_node.name == "air" or old_node.name == "ignore" then
					if math.random(0,255) <= node.prob then
						minetest.set_node(node_pos, node)
					end
				end

				-- so trees can grow through other trees leaves
				if minetest.registered_nodes[node.name].groups.log and minetest.registered_nodes[old_node.name].groups.leaves then
					if math.random(0,255) <= node.prob then
						minetest.set_node(node_pos, node)
					end
				end

				i = i + 1
			end
		end
	end
end
