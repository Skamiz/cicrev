--[[
An experiment in distorting the noise used for terrain height
to make it look diferent from the typical Perlin noise.

Two aditionall 2d noises are used to change the X and Z coordiante
at which the terrain noise is sampled.

Chunk generation time seems to be at about 0.04 s.
]]

-- change nodes as necessary
local c_dirt = minetest.get_content_id("cicrev:soil_with_grass")
local c_stone = minetest.get_content_id("df_stones:andesite")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- when the seed is too large it breaks things

local max_offset = 16
local offset_vector = vector.new(max_offset, max_offset, max_offset)

--noise parameters
local np_2d = {
	offset = 0,
	scale = 10,
	spread = {x = 40, y = 40, z = 40},
	seed = 0,
	octaves = 1,
	persist = 1.0,
	lacunarity = 1.0,
	-- flags = "noeased",
}
local np_2d_x = {
	offset = 0,
	scale = max_offset,
	spread = {x = 23, y = 23, z = 23},
	seed = 1,
	octaves = 1,
	persist = 1.0,
	lacunarity = 1.0,
	-- flags = "noeased",
}
local np_2d_y = {
	offset = 0,
	scale = max_offset,
	spread = {x = 23, y = 23, z = 23},
	seed = 2,
	octaves = 1,
	persist = 1.0,
	lacunarity = 1.0,
	-- flags = "noeased",
}

-- automatically detect necessary chunk_size
-- though in some circumstances you will want to increase it afterwards
local blocks_per_chunk = tonumber(minetest.settings:get("chunksize")) or 5
local side_lenght = blocks_per_chunk * 16
local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}
local extended_chunk_size = {x = side_lenght + 2 * max_offset, y = side_lenght + 2 * max_offset, z = side_lenght + 2 * max_offset}

-- create noise objects
local nobj_2d = noise_handler.get_noise_object(np_2d, extended_chunk_size)
local nobj_2d_x = noise_handler.get_noise_object(np_2d_x, chunk_size)
local nobj_2d_y = noise_handler.get_noise_object(np_2d_y, chunk_size)

-- persistent data table for node data
local data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)
	-- early exit if the mapgen doesn't operate in this hight range
	-- if maxp.y < -100 or minp.y > 100 then return end
	-- local t0 = minetest.get_us_time()

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)

	local minpo = minp - offset_vector

-- get noise data in a flat array
	local nvals_2d = nobj_2d:get_2d_map_flat(minp - offset_vector)
	local nvals_2d_x = nobj_2d_x:get_2d_map_flat(minp)
	local nvals_2d_y = nobj_2d_y:get_2d_map_flat(minp)

	math.randomseed(chunkseed)

	-- noise index, same as i3d
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				-- voxel area index, takes into acount overgenerated mapblocks
				local vi = area:index(x, y, z)
				-- index for flat noise maps, 3d and 2d respectively
				local i2d_xy = (z - minp.z) * side_lenght + (x - minp.x) + 1

				local nv_2d_x = math.ceil(nvals_2d_x[i2d_xy])
				local nv_2d_y = math.ceil(nvals_2d_y[i2d_xy])


				local i2d = (z - minp.z) * side_lenght + (x - minp.x) + 1
				local i2d = (z + nv_2d_y - minpo.z) * (side_lenght + 2 * max_offset) + (x + nv_2d_x - minpo.x) + 1
				local nv_2d = nvals_2d[i2d]


				if nv_2d > y then
					data[vi] = c_dirt
				end
				if nv_2d > y + 1 then
					data[vi] = c_stone
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

	-- print((minetest.get_us_time() - t0) / 1000000)
end)
