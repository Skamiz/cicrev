u = {}

--[[
	Undersmapling
	Prety sure this whole thing is a bust since the builtin noise is already undersampled
]]

local area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge={x = 80, y = 84, z = 80}}

local function clamp(n, min, max)
	return math.min(max, math.max(min, n))
end
mapgen.clamp = clamp

local function lerp(a, b, ratio)
	return a * (1 - ratio) + b * ratio
end
mapgen.lerp = lerp

local function ilerp(a, b, value)
	return (value - a) / (b - a)
end
mapgen.ilerp = ilerp

local function remap(in_a, in_b, out_a, out_b, value)
	return lerp(out_a, out_b, ilerp(in_a, in_b, value))
end
mapgen.remap = remap
-- asumes distance incerases along axis
-- lerps values for positions between pos and pos[axis] += distance
local function c_lerp(data, pos, axis, distance)
	local pos1 = table.copy(pos)
	local pos2 = table.copy(pos)
	pos2[axis] = pos2[axis] + distance
	local a = data[area:indexp(pos)]
	local b = data[area:indexp(pos2)]
	for i = 1, distance - 1 do
		pos1[axis] = pos[axis] + i
		assert(area:containsp(pos1), "Out of area.")
		data[area:indexp(pos1)] = lerp(a, b, i/distance)
	end
end


-- everything seems to be working correctlly, there is just no noticable difference
function u.interpolate_data(data)
	for x = 1, 80, 8 do
		for y = 1, 84, 4 do
			for z = 1, 80, 8 do
				pos000 = {x = x, y = y, z = z}
				pos100 = {x = x + 7, y = y, z = z}
				-- pos010 = {x = x, y = y + 3, z = z}
				pos001 = {x = x, y = y, z = z + 7}
				-- pos110 = {x = x + 7, y = y + 3, z = z}
				pos101 = {x = x + 7, y = y, z = z + 7}
				-- pos011 = {x = x, y = y + 3, z = z + 7}
				-- pos111 = {x = x + 7, y = y + 3, z = z + 7}

				c_lerp(data, pos000, "y", 3)
				c_lerp(data, pos100, "y", 3)
				c_lerp(data, pos001, "y", 3)
				c_lerp(data, pos101, "y", 3)

				for i = 1, 4 do
					c_lerp(data, {x = pos000.x, y = pos000.y + i - 1, z = pos000.z}, "z", 7)
				end
				for i = 1, 4 do
					c_lerp(data, {x = pos100.x, y = pos100.y + i - 1, z = pos100.z}, "z", 7)
				end
				for i = 1, 4 do
					for j = 1, 8 do
						c_lerp(data, {x = pos000.x, y = pos000.y + i - 1, z = pos000.z + j - 1}, "x", 7)
					end
				end

			end
		end
	end
end

function u.get_closeset_points(points_a, points_b)
	assert(#points_a > 0, "List of points_a is empty or not a list.")
	assert(#points_b > 0, "List of points_b is empty or not a list.")
	local p1, p2 = points_a[1], points_b[1]
	local min_distance = get_distance_squared(p1, p2)
	for i = 1, #points_a do
		for j = 1, #points_b do
			if get_distance_squared(points_a[i], points_b[j]) < min_distance then
				min_distance = get_distance_squared(points_a[i], points_b[j])
				p1 = points_a[i]
				p2 = points_b[j]
			end
		end
	end
	return p1, p2
end

--[[
	Mapgen
]]

function u.get_sphere_schematic(radius, node)
	local radius_2 = radius * radius
	local radius_floored = math.floor(radius)
	if not node then
		local node = {name = "stone"}
	end
	local empty = {name = "air", prob = 0}
	local size = ((radius_floored * 2) + 1)
	local middle = {x = radius_floored + 1, y = radius_floored + 1, z = radius_floored + 1}
	local data = {}
	local n = 1
	for z = 1, size do
		for y = 1, size do
			for x = 1, size do
				if get_distance_squared(middle, {x = x, y = y, z = z}) < radius_2 then
					data[n] = node
				else
					data[n] = empty
				end
				n = n + 1
			end
		end
	end
	local schem = {
		size = {x = size, y = size, z = size},
		data = data
	}
	return schem
end

function u.get_sphere_distace_data(radius)
	local radius_floored = math.floor(radius)

	local size = ((radius_floored * 2) + 1)
	local middle = {x = radius_floored + 1, y = radius_floored + 1, z = radius_floored + 1}

	local data = {}
	local n = 1
	for z = 1, size do
		for y = 1, size do
			for x = 1, size do
				data[n] = vector.distance(middle, {x = x, y = y, z = z})

				n = n + 1
			end
		end
	end

	return data, radius_floored
end
