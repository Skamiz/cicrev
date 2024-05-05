cicrev = {}

local directions = {}
directions.up = {x = 0, y = 1, z = 0}
directions.down = {x = 0, y = -1, z = 0}
directions.north = {x = 0, y = 0, z = 1}
directions.south = {x = 0, y = 0, z = -1}
directions.east = {x = 1, y = 0, z = 0}
directions.west = {x = -1, y = 0, z = 0}


function cicrev.get_touching_nodes(pos)
	local positions = {}
	for _, v in pairs(directions) do
		table.insert(positions, vector.add(pos, v))
	end
	return positions
end

function cicrev.get_touching_nodes_by_type(pos, node_name)
	local positions = {}
	for _, v in pairs(directions) do
		local location = vector.add(pos, v)
		if minetest.get_node(location).name == node_name then
			table.insert(positions, location)
		end
	end
	return positions
end

-- cuts up a one slot hotbar immage and reasembles it with the requested amount of slots
-- assumes that original hotbar image is 30 * 30 pixels
function cicrev.get_hotbar_image(base, length)
	length = math.min(32, math.max(1, length))

	local left_edge = "[combine\\:1x30\\:0,0=" .. base
	local middle = "[combine\\:28x30\\:-1,0=" .. base
	local right_edge = "[combine\\:1x30\\:-29,0=" .. base

	local hotbar_image = "[combine:" .. 28 * length + 2 .. "x30"

	for i = 0, length - 1 do
		hotbar_image = hotbar_image .. ":" .. 1 + i * 28 .. ",0=" .. middle
	end
	hotbar_image = hotbar_image .. ":0,0=" .. left_edge
	hotbar_image = hotbar_image .. ":" .. 28 * length + 1 .. ",0=" .. right_edge

	return hotbar_image
end

function cicrev.random_from_table(t)
	if #t < 1 then return {} end
	local reverse_table = {}
	for _, v in pairs(t) do
		table.insert(reverse_table, v)
	end
	return reverse_table[math.random(#reverse_table)]
end

--breadth first search for node type at specified position
--returns a table containing all the positions for the same node type up to a arbitrary limit to prevent overflow
function cicrev.detect_cluster(pos, max_cluster)
	local cluster = {}
	local queue = {} -- implement a general queue
	local node_name = minetest.get_node(pos).name
	local int = 0

	queue[1] = pos
	while queue[1] and int < max_cluster do
		cluster[minetest.pos_to_string(queue[1])] = queue[1]
		for _, pos in pairs(cicrev.get_touching_nodes_by_type(queue[1], node_name)) do
			if not cluster[minetest.pos_to_string(pos)] then
				table.insert(queue, pos)
			end
		end
		for k, v in ipairs(queue) do
			queue[k] = queue[k + 1]
		end
		int = int + 1
	end

	return cluster
end

function cicrev.leaf_decay(pos)
	local node = minetest.get_node(pos)
	local node_name = node.name
	local leaf_def = minetest.registered_nodes[node_name]._leaves
	if not leaf_def then return end
	local change = false
	local curent_distance = node.param2
	local distance = 10
	for _, v in pairs(cicrev.get_touching_nodes(pos)) do
		if leaf_def.grows_on[minetest.get_node(v).name] then
			distance = 0
		elseif minetest.get_node(v).name == node_name then
			distance = math.min(distance, minetest.get_node(v).param2)
		end
	end

	distance = distance + 1
	local change = curent_distance ~= distance
	if change then
		if distance > leaf_def.grow_distance then
			minetest.remove_node(pos)
		else
			minetest.set_node(pos, {name = node_name, param2 = distance})
		end
	end
	return change
end

local function get_arrow_direction(u, v)
	local dir = 0
	if math.abs(u) > math.abs(v) then
		if u > 0 then dir = 1 else dir = 3 end
	else
		if v < 0 then dir = 2 else dir = 0 end
	end
	return dir
end

function cicrev.get_arrow_rotation(user, pointed_thing)
	local normal = vector.subtract(pointed_thing.under, pointed_thing.above)
	local side = 0
	local direction = 0
	local pos = minetest.pointed_thing_to_face_pos(user, pointed_thing)
	pos = vector.subtract(pos, pointed_thing.above)

	direction = get_arrow_direction(pos.x, pos.z)
	if normal.z < 0 then side = 4
		direction = get_arrow_direction(pos.x, -pos.y)
	elseif normal.z > 0 then side = 8
		direction = get_arrow_direction(pos.x, pos.y)
	elseif normal.x < 0 then side = 12
		direction = get_arrow_direction(-pos.y, pos.z)
	elseif normal.x > 0 then side = 16
		direction = get_arrow_direction(pos.y, pos.z)
	elseif normal.y > 0 then side = 20
		direction = get_arrow_direction(-pos.x, pos.z)
	end
	return side + direction
end


local barks_to_strip = {
	["cicrev:log_oak"] = "cicrev:log_stripped_oak",
	["cicrev:log_dark"] = "cicrev:log_stripped_dark",
	["cicrev:log_chaktekok"] = "cicrev:log_stripped_chaktekok",
	["cicrev:log_chestnut"] = "cicrev:log_stripped_chestnut",

	["cicrev:bark_oak"] = "cicrev:bark_stripped_oak",
	["cicrev:bark_dark"] = "cicrev:bark_stripped_dark",
	["cicrev:bark_chaktekok"] = "cicrev:bark_stripped_chaktekok",
	["cicrev:bark_chestnut"] = "cicrev:bark_stripped_chestnut",
}

-- if pointed_thing.under is a suitable block, replace it with a stripped variant
function cicrev.strip_bark(itemstack, placer, pointed_thing)
	local node_under = minetest.get_node(pointed_thing.under)
	if  barks_to_strip[node_under.name] ~= nil then
		minetest.set_node(pointed_thing.under, {name = barks_to_strip[node_under.name], param2 = node_under.param2})
		itemstack:add_wear(500)
		return itemstack
	else
		return minetest.item_place(itemstack, placer, pointed_thing)
	end
end




function cicrev.register_stalactite(name, def1)
	if not def1.groups then def1.groups = {} end
	def1.groups["stalactite"] = 1

	local def2 = table.copy(def1)
	local def3 = table.copy(def1)

	shapes.register.pillar(name .. "_1", def1, 2)
	shapes.register.pillar(name .. "_2", def2, 4)
	shapes.register.pillar(name .. "_3", def3, 6)
end
