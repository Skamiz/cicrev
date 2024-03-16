--[[
Template mapgen

Chunk generation time seems to be at about 0.04 seconds.
]]


-- change nodes as necessary
local c_dirt = minetest.get_content_id("cicrev:soil_with_grass")
local c_stone = minetest.get_content_id("df_stones:andesite")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- when the seed is too large it breaks things

--noise parameters
local np_2d_xz = {
	offset = 0,
	scale = 1,
	spread = {x = 16, y = 16, z = 16},
	seed = 0,
	octaves = 2,
	persist = 0.8,
	lacunarity = 1.3,
	flags = "noeased",
}
local np_2d_xy = {
	offset = 0,
	scale = 1,
	spread = {x = 16, y = 16, z = 16},
	seed = 0,
	octaves = 2,
	persist = 0.8,
	lacunarity = 1.3,
	flags = "noeased",
}
local np_2d_zy = {
	offset = 0,
	scale = 1,
	spread = {x = 16, y = 16, z = 16},
	seed = 1,
	octaves = 2,
	persist = 0.8,
	lacunarity = 1.3,
	flags = "noeased",
}

-- automatically detect necessary chunk_size
-- though in some circumstances you will want to increase it afterwards
local blocks_per_chunk = tonumber(minetest.settings:get("chunksize")) or 5
local side_lenght = blocks_per_chunk * 16
local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}

-- create noise objects
local nobj_2d_xz = noise_handler.get_noise_object(np_2d_xz, chunk_size)
local nobj_2d_xy = noise_handler.get_noise_object(np_2d_xy, chunk_size)
local nobj_2d_zy = noise_handler.get_noise_object(np_2d_zy, chunk_size)

-- persistent data table for node data
local data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)
	-- math.randomseed(chunkseed)
	-- early exit if the mapgen doesn't operate in this hight range
	-- if maxp.y < -100 or minp.y > 100 then return end

	-- local t0 = minetest.get_us_time()

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea(emin, emax)
	vm:get_data(data)

	-- get noise data in a flat array
	local nvals_2d_xz = nobj_2d_xz:get_2d_map_flat({x = minp.x, z = minp.z})
	local nvals_2d_xy = nobj_2d_xy:get_2d_map_flat({x = minp.x, z = minp.y})
	local nvals_2d_zy = nobj_2d_zy:get_2d_map_flat({x = minp.y, z = minp.z})

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				-- voxel area index, takes into acount overgenerated mapblocks
				local vi = area:index(x, y, z)
				-- index for flat noise maps, 3d and 2d respectively
				local i2d_xz = (z - minp.z) * side_lenght + (x - minp.x) + 1
				local i2d_xy = (y - minp.y) * side_lenght + (x - minp.x) + 1
				local i2d_zy = (z - minp.z) * side_lenght + (y - minp.y) + 1

				local nv_2d_xz = nvals_2d_xz[i2d_xz]
				local nv_2d_xy = nvals_2d_xy[i2d_xy]
				local nv_2d_zy = nvals_2d_zy[i2d_zy]


				if nv_2d_xy + nv_2d_zy + nv_2d_xz - y/10 > 0 then
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
	-- print(((minetest.get_us_time() - t0) / 1000) .. " ms" )
end)
