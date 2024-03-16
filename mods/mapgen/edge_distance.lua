local c_grass = minetest.get_content_id("cicrev:dirt_with_grass")
local c_dirt = minetest.get_content_id("cicrev:loam")
local c_moss = minetest.get_content_id("cicrev:peat_with_moss")
local c_peat = minetest.get_content_id("cicrev:peat")
local c_sand = minetest.get_content_id("cicrev:sand")
local c_gravel = minetest.get_content_id("cicrev:gravel")
local c_water = minetest.get_content_id("cicrev:water_source")

local soils = {"soil", "loam", "clay", "silt", "sand", "peat"}

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- necesary, otherwise it break things

-- increasing ratio moves from a to b
local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end

local function get_biome_point(minp)
	math.randomseed(minetest.hash_node_position(minp) + world_seed)

	local stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(sedimentary))
    if minp.y < -80 then
        stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(metamorphic))
    end
    if minp.y < -160 then
        stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(i_intrusive))
    end
	local soil = minetest.get_content_id("cicrev:" .. cicrev.random_from_table(soils))

	local biome_point = {
		-- for some reason this breaks
		-- x = minp.x + 40,
		-- z = minp.z + 40 ,--* (math.ceil(minp.z/80) % 2),
		x = math.random(minp.x, minp.x + 79),
		z = math.random(minp.z, minp.z + 79),
		y = math.random(-10, 10),
		stone = stone,
		soil = soil,
	}
	-- minetest.chat_send_all(math.floor(minp.z/80) % 2)
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
	local po = d_z / d_x -- beware of division by 0

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
	-- TODO: isn't there a neater way to do this?

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
			-- local dist = get_distance_squared(x, z, bp.x, bp.z)
			local dist = get_distance_squared(x, z, inter_x, inter_z)
			if dist < dist2 then
				dist2 = dist
				second_closest = bp
			end
		end
	end

	local third_closest
	local dist3 = 999999
	for _, bp in pairs(biome_points) do
		if bp ~= closest and bp ~= second_closest then
			local inter_x, inter_z = get_point_line_intersection(x, z, closest, bp)
			-- local dist = get_distance_squared(x, z, bp.x, bp.z)
			local dist = get_distance_squared(x, z, inter_x, inter_z)
			if dist < dist3 then
				dist3 = dist
				third_closest = bp
			end
		end
	end

	return closest, second_closest, third_closest, math.sqrt(dist2), math.sqrt(dist3)
end

-- distance to edge
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
	-- local distance_map = get_distance_map({x = minp.x, z = minp.z, y = -32})
	for x = minp.x, minp.x + 79 do
		for z = minp.z, minp.z  + 79 do
			local nv = noise[(z-minp.z) * 80 + x-minp.x + 1] -- noise used to make interpolation more un-even
			local bp1, bp2, bp3, dist2, dist3 = get_nearest_biome_point(x, z, biome_points)

			-- local dist = distance_map[(z-minp.z) * 80 + x-minp.x + 1]
			local height = bp1.y

			local lim2 = (math.abs(bp1.y - bp2.y) / 1)
			local lim3 = (math.abs(bp1.y - bp3.y) / 1)

			-- if dist2 <= lim2 then
			-- 	local influence2 = math.max(1 - (dist2/lim2), 0)
			-- 	height = lerp(bp1.y, bp2.y, influence2 / 2)
			-- elseif dist3 <= lim3 then
			-- 	local influence3 = math.max(1 - (dist3/lim3), 0)
			-- 	height = lerp(bp1.y, bp3.y, influence3 / 2)
			-- 	-- height = math.max(lerp(bp1.y, bp3.y, influence3 / 2), height)
			-- end
			if dist2 <= lim2 then
				local influence2 = math.max(1 - (dist2/lim2), 0)
				height = lerp(bp1.y, bp2.y, influence2 / 2)
			end
			if dist3 <= lim3 then
				local influence3 = math.max(1 - (dist3/lim3), 0)
				local h = lerp(bp1.y, bp3.y, influence3 / 2)
				if bp3.y > bp1.y then
					height = math.max(h, height)
				else
					height = math.min(h, height)
				end
				-- height = math.max(lerp(bp1.y, bp3.y, influence3 / 2), height)
			end

			-- local dist23 = get_distance(x, z, bp2, bp3)
			-- local lim23 = (math.abs(bp2.y - bp3.y) / 2)

			-- if dist2 < lim2 and dist3 < lim3 and dist23 < lim23 then
			-- if dist2 <= lim2 and dist3 <= lim3 then
			-- 	height = (bp1.y + bp2.y + bp3.y) / 3
			--
			--
			-- 	-- local influence1 = 1
			-- 	-- local influence2 = 1 - (dist2/lim2)
			-- 	-- local influence3 = 1 - (dist3/lim3)
			-- 	--
			-- 	-- local sum = influence1 + influence2 + influence3
			-- 	-- influence1 = influence1 / sum
			-- 	-- influence2 = influence2 / sum
			-- 	-- influence3 = influence3 / sum
			-- 	--
			-- 	-- height = (bp1.y * influence1) + (bp2.y * influence2) + (bp3.y * influence3)
			--
			-- 	--
			-- 	-- local influence2 = math.max(1 - (dist2/lim2), 0)
			-- 	-- local influence3 = math.max(1 - (dist3/lim3), 0)
			-- 	-- local influence23 = math.min(dist23/lim23, 1)
			--
			-- 	-- local h = lerp(bp1.y, bp2.y, influence2 / 2)
			-- 	-- height = lerp(h, bp3.y, influence3 / 2)
			--
			-- 	-- local influence23 = math.max(1 - (dist23/lim23), 0)
			-- 	-- influence3 = math.max(influence3, influence23)
			-- 	-- height = ((bp1.y * ((3) - (influence2 + (influence3)))) + (bp2.y * influence2) + (bp3.y * influence3)) / (3)
			--
			-- 	-- height = ((bp1.y * ((3 - influence23) - (influence2 + (influence3*(1-influence23))))) + (bp2.y * influence2) + (bp3.y * influence3 * (1-influence23))) / (3-influence23)
			-- end
			-- if dist2 <= lim2 or dist3 <= lim3 then
			-- 	height = (bp1.y + bp2.y + bp3.y) / 3
			-- end

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
        persist = 0.63,
        lacunarity = 2.0,
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
local nobj_generic = noise_handler.get_noise_object(np_generic, chunk_size)
local nobj_terrain_height = noise_handler.get_noise_object(np_terrain_height, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)
	local t0 = minetest.get_us_time()
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
						-- data[vi] = c_peat
						data[vi] = c_moss
					end
				elseif biome.y == 1 and y < 0 and y < t_height then
	                    data[vi] = c_peat
				else

	                if y < t_height and y >= 0 then
	                    -- data[vi] = biome.soil
						data[vi] = c_grass
						if biome.soil == c_sand then data[vi] = c_sand end
	                end

	                if y < t_height and y < 0 then
						-- data[vi] = biome.soil
	                    data[vi] = c_gravel
	                end

					if y < t_height - 1 then
	                    data[vi] = biome.soil
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

	print("Chunk generation time: " .. (minetest.get_us_time() - t0)/1000 .. " ms")
end)
