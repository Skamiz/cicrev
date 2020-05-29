-- TODO: no flat walls at chunk borders

local offset_vectors = {
	{x = 80, y = 0, z = 0},
	{x = -80, y = 0, z = 0},
	{x = 0, y = 80, z = 0},
	{x = 0, y = -80, z = 0},
	{x = 0, y = 0, z = 80},
	{x = 0, y = 0, z = -80},
}

local function place_area_in_area(data_1, area_1, data_2, area_2)
	for i in area_1:iterp(area_1.MinEdge, area_1.MaxEdge) do
		local pos = area_1:position(i)
		if area_2:containsp(pos) then
			local n = area_2:index(pos)
			area_2[n] = area_1[i]
		end
	end
end


local function get_area_overlap(area_1, area_2, offset)
	local o = offset
	local overlap = {}
	for i in area_1:iterp(area_1.MinEdge, area_1.MaxEdge) do
		local pos = area_1:position(i)
		if area_2:contains(pos.x + o.x, pos.y + o.y, pos.z + o.z) then
			overlap[i] = area_2:index(pos.x + o.x, pos.y + o.y, pos.z + o.z)
		end
	end
	return overlap
end

local function get_random_points(minp, n, offset_v)
	offset_v = offset_v or {x=0, y=0, z=0}
	local points = {}
	math.randomseed(minetest.hash_node_position(minp))
	for i = 1, n do
		points[#points + 1] = {	x = offset_v.x + math.random(10, 70),
								y = offset_v.y + math.random(10, 70),
								z = offset_v.z + math.random(10, 70),}
	end
	return points
end

local function reset_data(data, value)
	for i = 1, 80*80*80 do
		data[i] = value
	end
	return data
end

np_cave_roughnes = {
    offset = 0,
    scale = 1.5,
    spread = {x = 40, y = 40, z = 40},
    seed = 9,
    octaves = 2,
    persist = 0.63,
    lacunarity = 16.0,
}

local nobj_cr

np_caves = {
    offset = 1.5,
    scale = 3,
    spread = {x = 300, y = 300, z = 300},
    seed = 9,
    octaves = 2,
    persist = 0.63,
    lacunarity = 2.0,
}

local nobj_caves

local area = VoxelArea:new({MinEdge = {x = 1, y = 1, z = 1}, MaxEdge = {x = 80, y = 80, z = 80}})

local schem, r = u.get_sphere_distace_data(3)
local s_area = VoxelArea:new({MinEdge = {x = -r, y = -r, z = -r}, MaxEdge = {x = r, y = r, z = r}})

local distance_data = {}
local cr_data = {}

function get_cave_density_data(minp)
	distance_data = reset_data(distance_data, 1000)

	nobj_caves = nobj_caves or minetest.get_perlin(np_caves)
	nobj_cr = nobj_cr or minetest.get_perlin_map(np_cave_roughnes, {x = 80, y = 80, z = 80})

	local points = get_random_points(minp, math.ceil(nobj_caves:get_3d(minp)))
	if #points == 0 then return false end

	for i = 2 , #points do
		local line = make_line(points[i-1], points[i])
		for _, p in ipairs(line) do
	        if area:containsp(p) then
				local overlap = get_area_overlap(s_area, area, p)
				for k, v in pairs(overlap) do
					distance_data[v] = math.min(distance_data[v], schem[k])
				end
	        end
	    end
	end

	for k, offset in pairs(offset_vectors) do
		local pos = vector.add(minp, offset)

		local other_points = get_random_points(pos, math.ceil(nobj_caves:get_3d(pos)), offset)
		if not (#other_points == 0) then

			local p1, p2 = u.get_closeset_points(points, other_points)

			if k % 2 == 1 then
				p1, p2 = p2, p1
			end

			local line = make_line(p1, p2)
	        for _, p in ipairs(line) do
				if area:containsp(p) then
					local overlap = get_area_overlap(s_area, area, p)
					for k, v in pairs(overlap) do
						distance_data[v] = math.min(distance_data[v], schem[k])
					end
		        end
	        end
		end
	end

	nobj_cr:get_3d_map_flat(minp, cr_data)

	for k, v in pairs(cr_data) do
		distance_data[k] = distance_data[k] + (v * 1)
	end

	return distance_data
end
