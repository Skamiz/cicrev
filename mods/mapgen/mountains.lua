local c_dirt = minetest.get_content_id("cicrev:soil_with_grass")
local c_stone = minetest.get_content_id("df_stones:andesite")
local c_clay = minetest.get_content_id("df_stones:claystone")


local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end


minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- necesary, otherwise it breaks things

--noise parameters
-- local np_3d = {
--     offset = 0,
--     scale = 10,
--     spread = {x = 10, y = 10, z = 10},
--     seed = 0,
--     octaves = 1,
--     persist = 1,
--     lacunarity = 1.0,
-- }

-- terrain
local np_2d_t = {
    offset = 0,
    scale = 1,
    spread = {x = 100, y = 100, z = 100},
    seed = 0,
    octaves = 2,
    persist = 0.15,
    lacunarity = 6.0,
	flags = "eased",
}
-- interpolation
local np_2d_i = {
    offset = 0,
    scale = 1,
    spread = {x = 30, y = 30, z = 30},
    seed = 1,
    octaves = 1,
    persist = 1.0,
    lacunarity = 1.0,
	flags = "noeased, absvalue",
}

local blocks_per_chunk = tonumber(minetest.settings:get("chunksize")) or 5
local side_lenght = blocks_per_chunk * 16
local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}

-- local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
-- local nobj_2d_t = noise_handler.get_noise_object(np_2d_t, chunk_size)
-- local nobj_2d_i = noise_handler.get_noise_object(np_2d_i, chunk_size)
noise_handler.register_dynamic_noise("terrain", np_2d_t, chunk_size)
noise_handler.register_dynamic_noise("interpolation", np_2d_i, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    -- local nvals_3d = nobj_3d:get_3d_map_flat(minp)
	-- local nvals_2d_t = nobj_2d_t:get_2d_map_flat(minp)
	-- local nvals_2d_i = nobj_2d_i:get_2d_map_flat(minp)
    local nvals_2d_t = noise_handler.noises["terrain"]:get_2d_map_flat(minp)
    local nvals_2d_i = noise_handler.noises["interpolation"]:get_2d_map_flat(minp)



    math.randomseed(chunkseed)

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				-- voxel area index, takes into acount overgenerated mapblocks
				local vi = area:index(x, y, z)
				-- index for flat noise maps, 3d and 2d respectively
				local i3d = (z - minp.z) * side_lenght * side_lenght + (y - minp.y) * side_lenght + (x - minp.x) + 1
				local i2d = (z - minp.z) * side_lenght + (x - minp.x) + 1

				-- local nv_3d = nvals_3d[i3d]
				local nv_2d_t = nvals_2d_t[i2d]
				local nv_2d_i = nvals_2d_i[i2d]


				if y < nv_2d_t * 5 then
					data[vi] = c_dirt
				end


				local inf = lerp(-0.1, 1.1, 1 - nv_2d_t * nv_2d_t)
				local t = lerp(nv_2d_t * 50, -3, inf * nv_2d_i)
				-- t = nv_2d_t * 50
				if y < t then
					data[vi] = c_stone
					if nv_2d_i < 0.2 then
						data[vi] = c_clay
					elseif nv_2d_i > 0.3 and nv_2d_t < 0.5 then
						data[vi] = c_dirt
					end
				end

			end
		end
	end

	vm:set_data(data)
    -- minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
end)
