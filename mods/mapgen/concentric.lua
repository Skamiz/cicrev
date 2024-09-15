--[[
Mapgen: Concentric

Goal:
Central island with huge mountain in the middle.
Surrounded by a ring of stone spikes jutting from the ocean.
Surrounded by a ring of island chains.
Four medium islands in the corners.

]]


local SCALE = 1/50

local surface_level = 0
local island_radius = 10000 * SCALE

local mountain_height = 1000 * SCALE
local mountain_offshoots = 17

local ocean_depth = -200 * SCALE







-- change nodes as necessary
local c_dirt = minetest.get_content_id("cicrev:soil_with_grass")
local c_stone = minetest.get_content_id("c_stone:granite")
local c_stone_2 = minetest.get_content_id("c_stone:slate")
local c_water = minetest.get_content_id("cicrev:water_source")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- when the seed is too large it breaks things
math.randomseed(world_seed)
local rand_turn = math.random() * math.pi

--noise parameters
-- local np_3d = {
-- 	offset = 0,
-- 	scale = 10,
-- 	spread = {x = 10, y = 10, z = 10},
-- 	seed = 0,
-- 	octaves = 1,
-- 	persist = 1.0,
-- 	lacunarity = 1.0,
-- }

local np_2d = {
	offset = 0,
	scale = 0.1,
	spread = {x = 2111 * SCALE, y = 2111 * SCALE, z = 2111 * SCALE},
	seed = 0,
	octaves = 3,
	persist = 0.7,
	lacunarity = 2.3,
	flags = "noeased",
}

-- automatically detect necessary chunk_size
-- though in some circumstances you will want to increase it afterwards
local blocks_per_chunk = tonumber(minetest.settings:get("chunksize")) or 5
local side_lenght = blocks_per_chunk * 16
local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}

-- create noise objects
-- local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)

-- persistent data table for node data
local data = {}

-- height that the mountian adds to terrain
local function get_central_mountain_height(x, z)
	local dist = vector.new(x, 0, z):length()

	local angle = math.atan2(z, x) - math.pi/2 -- math.pi changes where the zero angle is
	angle = angle + nobj_2d:get_2d(vector.new(x, 0, z))

	local hillines = math.cos(angle * mountain_offshoots)
	hillines = hillines + math.cos(angle * mountain_offshoots * 3) * 0.5

	local max_height = mapgen.remap(0, island_radius^1, mountain_height, 0, dist^1)
	local min_height = max_height/2

	if dist < island_radius/5 then
		min_height = mapgen.remap((island_radius/5)^1, 0, min_height, max_height, dist^1)
	end

	local height = mapgen.remap(-1, 1, min_height, max_height, hillines)

	return height
end

local function get_terrain_height(x, z)
	local dist = vector.new(x, 0, z):length()
	local height = mapgen.remap(0, island_radius, island_radius / 10, 0, dist)


	-- height = height + get_central_mountain_height(x, z)
	height = height + nobj_2d:get_2d(vector.new(x, 0, z)) * 20

	height = math.max(height, ocean_depth)

	return height + surface_level

	-- local height = math.abs(nobj_2d:get_2d(vector.new(x, 0, z)))
	-- height = mapgen.remap(0, island_radius, height *100, 0, dist) - 1
	-- return height
end


mapgen.collect_sample = function(x, z)
	local t0 = minetest.get_us_time()
	local sample = {}
	local height = get_terrain_height(x, z)
	sample.height = height

	return sample
end

minetest.register_on_generated(function(minp, maxp, chunkseed)
	math.randomseed(chunkseed)
	-- early exit if the mapgen doesn't operate in this hight range
	-- if maxp.y < -100 or minp.y > 100 then return end

	-- local t0 = minetest.get_us_time()

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea(emin, emax)
	vm:get_data(data)

	-- get noise data in a flat array
	-- local nvals_3d = nobj_3d:get_3d_map_flat(minp)
	local nvals_2d = nobj_2d:get_2d_map_flat(minp)

	-- noise index, same as i3d
	for z = minp.z, maxp.z do
		for x = minp.x, maxp.x do
			local i2d = (z - minp.z) * side_lenght + (x - minp.x) + 1
			local nv_2d = nvals_2d[i2d]

			local height = get_terrain_height(x, z)


			for y = minp.y, maxp.y do
				-- voxel area index, takes into acount overgenerated mapblocks
				local vi = area:index(x, y, z)
				-- index for flat noise maps, 3d and 2d respectively
				-- local i3d = (z - minp.z) * side_lenght * side_lenght + (y - minp.y) * side_lenght + (x - minp.x) + 1
				-- local i2d = (z - minp.z) * side_lenght + (x - minp.x) + 1
				--
				-- local nv_3d = nvals_3d[i3d]
				-- local nv_2d = nvals_2d[i2d]


				if y <= surface_level then
					data[vi] = c_water
				end

				if y <= height then
					if y % 2 == 0 then
						data[vi] = c_stone
					else
						data[vi] = c_stone_2
					end
				end

			end
		end
	end

	-- finishing up
	vm:set_data(data)
	-- minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
	-- print(((minetest.get_us_time() - t0) / 1000) .. " ms" )
end)
