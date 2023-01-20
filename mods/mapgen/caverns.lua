local c_dirt = minetest.get_content_id("cicrev:dirt_with_grass")
local c_stone = minetest.get_content_id("df_stones:andesite")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- necesary, otherwise it breaks things

local cavern_top = 10
local cavern_bottom = -50

--noise parameters
local np_3d = {
    offset = 0,
    scale = 10,
    spread = {x = 10, y = 10, z = 10},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
	flags = "absvalue",
}

local np_2d = {
    offset = 0,
    scale = 10,
    spread = {x = 80, y = 80, z = 80},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
	flags = "noeased",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_3d = nobj_3d:get_3d_map_flat(minp)
    local nvals_2d = nobj_2d:get_2d_map_flat(minp)



    math.randomseed(chunkseed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)
				-- index for flat noise maps, 3d and 2d respectively
				local i3d = (z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1
				local i2d = (z - minp.z) * 80 + (x - minp.x) + 1
				ni = ni + 1

				local nv_3d = nvals_3d[i3d]
                local nv_2d = nvals_2d[i2d]





				-- if nv_2d > y then
				-- 	data[vi] = c_dirt
				-- end

				if y <= 0 and nv_2d > 0 then
					data[vi] = c_stone
				end
				-- if y <= 0 and nv_3d < 1 then
				-- 	data[vi] = c_stone
				-- end

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
