-- TODO: put constants in thier own file, into the table c
local c_grass = minetest.get_content_id("cicrev:dirt_with_grass")
local c_dirt = minetest.get_content_id("cicrev:dirt")
local c_sand = minetest.get_content_id("cicrev:sand")
local c_gravel = minetest.get_content_id("cicrev:gravel")
local c_water = minetest.get_content_id("cicrev:water_source")

minetest.set_mapgen_setting("water_level", "0", true)

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
        scale = 1,
        spread = {x = 200, y = 200, z = 200},
        seed = 0,
        octaves = 1,
        -- persist = 0.63,
        -- lacunarity = 2.0,
}

local side_lenght = 80
local chunk_size = {x = 80, y = 84, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}
local nobj_generic = get_noise_object(np_generic, chunk_size)
local nobj_terrain_height = get_noise_object(np_terrain_height, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)

    local noise_values_generic_3d = nobj_generic:get_3d_map_flat(minp)
    local nvs_terrain_height = nobj_terrain_height:get_2d_map_flat(minp)
    u.interpolate_data(noise_values_generic_3d)

    math.randomseed(blockseed)

    local stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(sedimentary))
    if maxp.y < 0 then
        stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(metamorphic))
    end
    if maxp.y < -80 then
        stone = minetest.get_content_id("df_stones:" .. cicrev.random_from_table(i_intrusive))
    end

    local minv, maxv = 0, 0

	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				local vi = area:index(x, y, z)

                local nv_3d = noise_values_generic_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 1, z - minp.z + 1)]
                local nv_3d_1 = noise_values_generic_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 2, z - minp.z + 1)]
                local nv_3d_4 = noise_values_generic_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 5, z - minp.z + 1)]
                local nv_terrain_height = nvs_terrain_height[(z-minp.z) * chunk_size.x + x-minp.x + 1]

                if y < 0 then
                    data[vi] = c_water
                end

                if nv_3d - (y / 20) + nv_terrain_height > 0 then
                    if y < 2 then
                        data[vi] = c_sand
                        if y < -3 then
                            data[vi] = c_gravel
                        end
                    else
                        data[vi] = c_grass
                    end
                    if nv_3d_1 - ((y + 1) / 20) + nv_terrain_height > 0 then
                        data[vi] = c_dirt
                    end
                    if nv_3d_4 - ((y + 4) / 20) + nv_terrain_height > 0 then
                        data[vi] = stone
                    end
                end
			end
		end
	end

	vm:set_data(data)
	vm:write_to_map()
end)
