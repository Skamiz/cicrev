-- TODO: put constants in thier own file, into the table c
local c_grass = minetest.get_content_id("cicrev:dirt_with_grass")
local c_dirt = minetest.get_content_id("cicrev:dirt")
local c_moss = minetest.get_content_id("cicrev:peat_with_moss")
local c_peat = minetest.get_content_id("cicrev:peat")
local c_sand = minetest.get_content_id("cicrev:sand")
local c_gravel = minetest.get_content_id("cicrev:gravel")
local c_water = minetest.get_content_id("cicrev:water_source")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- necesary, otherwise it break things

local function get_biome_point(minp)
	math.randomseed(minetest.hash_node_position(minp) + world_seed)

	local stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(sedimentary))
    if minp.y < -80 then
        stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(metamorphic))
    end
    if minp.y < -160 then
        stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(i_intrusive))
    end

	local biome_point = {
		x = math.random(minp.x, minp.x + 79),
		z = math.random(minp.z, minp.z + 79),
		y = math.random(-10, 10),
		stone = stone,
	}
	return biome_point
end

local function get_biome_points(minp)
	local biome_points = {}
	for x = minp.x - 80, minp.x + 80, 80 do
		for z = minp.z - 80, minp.z + 80, 80 do
			table.insert(biome_points, get_biome_point({x = x, y = minp.y, z = z}))
		end
	end
	return biome_points
end

local function get_distance_squared(x1, y1, x2, y2)
	return (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
end

-- o_x, o_z coordinates of node
-- bp1, bp2 position of biome centers
-- returns closeset point to node from border between biomes

local function get_point_line_intersection(o_x, o_z, bp1, bp2)
	local m_x, m_z = (bp1.x + bp2.x) / 2, (bp1.z + bp2.z) / 2
	local d_x, d_z = bp2.x - bp1.x, bp2.z - bp1.z
	local po = d_z / d_x

	local v = (po * (po * (o_x - m_x) + (m_z - o_z))) / ((po * po) + 1)
	local x = m_x + v
	local z = m_z + (v * -(1/po))

	return x, z
end

local function get_distance(o_x, o_z, bp1, bp2)
	local x, z = get_point_line_intersection(o_x, o_z, bp1, bp2)
	return vector.distance({x = x, z = z, y = 0}, {x = o_x, z = o_z, y = 0})
end

local function get_nearest_biome_point(x, z, biome_points)
	local closest
	local dist1 = 99999
	for _, bp in pairs(biome_points) do
		local dist = get_distance_squared(x, z, bp.x, bp.z)
		if dist < dist1 then
			dist1 = dist
			closest = bp
		end
	end

	local second_closest
	local dist2 = 999999
	for _, bp in pairs(biome_points) do
		if bp ~= closest then
			local inter_x, inter_z = get_point_line_intersection(x, z, closest, bp)
			local dist = get_distance_squared(x, z, inter_x, inter_z)
			if dist < dist2 then
				dist2 = dist
				second_closest = bp
			end
		end
	end

	return closest, second_closest
end

local distance_buffer = {}
local function get_distance_map(minp)
	local biome_points = get_biome_points(minp)
	for x = minp.x, minp.x + 79 do
		for z = minp.z, minp.z  + 79 do
			local bp1, bp2 = get_nearest_biome_point(x, z, biome_points)
			local dist = get_distance(x, z, bp1, bp2)
			distance_buffer[(z-minp.z) * 80 + x-minp.x + 1] = dist
		end
	end
	return distance_buffer
end

local height_buffer = {}
local function get_height_map(minp, noise)
	local biome_points = get_biome_points(minp)
	local distance_map = get_distance_map({x = minp.x, z = minp.z, y = -32})
	for x = minp.x, minp.x + 79 do
		for z = minp.z, minp.z  + 79 do
			local nv = noise[(z-minp.z) * 80 + x-minp.x + 1] -- noise used to make interpolation more un-even
			local bp1, bp2 = get_nearest_biome_point(x, z, biome_points)
			local dist = distance_map[(z-minp.z) * 80 + x-minp.x + 1]
			local height = bp1.y
			local lim = 5 --+ nv*3
			if dist < lim then
				height = ((dist/lim) * bp1.y) + ((1 - (dist/lim)) * ((bp1.y + bp2.y) / 2))
			end
			height_buffer[(z-minp.z) * 80 + x-minp.x + 1] = height
		end
	end
	return height_buffer
end

local biome_buffer = {}
local function get_biome_map(minp)
	local biome_points = get_biome_points(minp)
	for x = minp.x, minp.x + 79 do
		for z = minp.z, minp.z  + 79 do
			biome_buffer[(z-minp.z) * 80 + x-minp.x + 1] = get_nearest_biome_point(x, z, biome_points)
		end
	end
	return biome_buffer
end



--noise parameters
np_generic = {
        offset = 0,
        scale = 1,
        spread = {x = 10, y = 10, z = 10},
        seed = 0,
        octaves = 1,
        -- persist = 0.63,
        -- lacunarity = 2.0,
}

np_terrain_height = {
        offset = 0,
        scale = 2,
        spread = {x = 40, y = 40, z = 40},
        seed = 0,
        octaves = 4,
        persist = 0.63,
        lacunarity = 2.0,
}

local side_lenght = 80
local chunk_size = {x = 80, y = 84, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}
local nobj_generic = get_noise_object(np_generic, chunk_size)
local nobj_terrain_height = get_noise_object(np_terrain_height, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)

    -- local noise_values_generic_3d = nobj_generic:get_3d_map_flat(minp)
    local nvs_terrain_height = nobj_terrain_height:get_2d_map_flat(minp)
	local height_map = get_height_map(minp, nvs_terrain_height)
	local distance_map = get_distance_map({x = minp.x, z = minp.z, y = -32})
	local biome_map = get_biome_map(minp)

    math.randomseed(blockseed)

    local stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(sedimentary))
    if maxp.y < 0 then
        stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(metamorphic))
    end
    if maxp.y < -80 then
        stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(i_intrusive))
    end

	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				local vi = area:index(x, y, z)

                -- local nv_3d = noise_values_generic_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 1, z - minp.z + 1)]
                -- local nv_3d_1 = noise_values_generic_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 2, z - minp.z + 1)]
                -- local nv_3d_4 = noise_values_generic_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 5, z - minp.z + 1)]
                -- local nv_terrain_height = nvs_terrain_height[(z-minp.z) * 80 + x-minp.x + 1]

				local terrain_height = height_map[(z-minp.z) * 80 + x-minp.x + 1]
				-- local terrain_height = distance_map[(z-minp.z) * 80 + x-minp.x + 1]
				local biome = biome_map[(z-minp.z) * 80 + x-minp.x + 1]
				assert(terrain_height, "index: " .. (z-minp.z) * 80 + x-minp.x + 1)

				local t_height = terrain_height

                if y <= 0 then
                    data[vi] = c_water
                end

				if biome.y == 1 and y == 0 and y < t_height then
					if math.random() < 0.6 then
						data[vi] = c_moss
					end
				elseif biome.y == 1 and y < 0 and y < t_height then
	                    data[vi] = c_peat
				else

	                if y < t_height and y > 0 then
	                    data[vi] = c_grass
	                end

	                if y < t_height and y < 0 then
	                    data[vi] = c_gravel
	                end

					if y < t_height - 1 then
	                    data[vi] = c_dirt
	                end
				end

                if y < t_height - 2 then
                    data[vi] = biome.stone
                end
			end
		end
	end

	-- show biome point position
	data[area:indexp(get_biome_point(minp))] = c_grass

	vm:set_data(data)
	-- vm:write_to_map()

	vm:update_liquids()
	vm:calc_lighting()
	vm:write_to_map()
end)
