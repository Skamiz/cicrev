-- change nodes as necessary
local c_dirt = minetest.get_content_id("cicrev:soil_with_grass")
local c_stone = minetest.get_content_id("df_stones:andesite")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- when the seed is too large it breaks things

--noise parameters
local np_2d_terrain = {
	offset = 0,
	scale = 5,
	spread = {x = 45, y = 45, z = 45},
	seed = 1,
	octaves = 1,
	persist = 1.0,
	lacunarity = 1.0,
	-- flags = "absvalue",
}
local np_2d_plateau = {
	offset = -0.5,
	scale = 1,
	spread = {x = 40, y = 40, z = 40},
	seed = 0,
	octaves = 1,
	persist = 1.0,
	lacunarity = 1.0,
	flags = "absvalue",
}
local np_2d_pl_height = {
	offset = 10,
	scale = 5,
	spread = {x = 80, y = 80, z = 40},
	seed = 2,
	octaves = 1,
	persist = 1.0,
	lacunarity = 1.0,
	-- flags = "absvalue",
}
local np_2d_pl_steep = {
	offset = 0,
	scale = 1,
	spread = {x = 50, y = 50, z = 50},
	seed = 3,
	octaves = 1,
	persist = 1.0,
	lacunarity = 1.0,
}

-- automatically detect necessary chunk_size
-- though in some circumstances you will want to increase it afterwards
local blocks_per_chunk = tonumber(minetest.settings:get("chunksize")) or 5
local side_lenght = blocks_per_chunk * 16
local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}

-- create noise objects
local nobj_2d_terrain = noise_handler.get_noise_object(np_2d_terrain, chunk_size)
local nobj_2d_plateau = noise_handler.get_noise_object(np_2d_plateau, chunk_size)
local nobj_2d_pl_height = noise_handler.get_noise_object(np_2d_pl_height, chunk_size)
local nobj_2d_pl_steep = noise_handler.get_noise_object(np_2d_pl_steep, chunk_size)

-- persistent data table for node data
local data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)
	-- early exit if the mapgen doesn't operate in this hight range
	-- if maxp.y < -100 or minp.y > 100 then return end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)

	-- get noise data in a flat array
	local nvals_2d_terrain = nobj_2d_terrain:get_2d_map_flat(minp)
	local nvals_2d_plateau = nobj_2d_plateau:get_2d_map_flat(minp)
	local nvals_2d_pl_height = nobj_2d_pl_height:get_2d_map_flat(minp)
	local nvals_2d_pl_steep = nobj_2d_pl_steep:get_2d_map_flat(minp)

	math.randomseed(chunkseed)

	-- noise index, same as i3d
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				-- voxel area index, takes into acount overgenerated mapblocks
				local vi = area:index(x, y, z)
				-- index for flat noise maps, 3d and 2d respectively
				local i2d = (z - minp.z) * side_lenght + (x - minp.x) + 1

				local nv_2d_t = nvals_2d_terrain[i2d]
				local nv_2d_pl = nvals_2d_plateau[i2d]
				local nv_2d_plh = nvals_2d_pl_height[i2d]
				local nv_2d_pls = nvals_2d_pl_steep[i2d]*100

				local terrain = nv_2d_t
				local terrain = 1

				if terrain > y then
					data[vi] = c_dirt
				end

				local density = y/nv_2d_pls + nv_2d_pl

				if density > 0 and y < nv_2d_plh + nv_2d_t then
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
end)
