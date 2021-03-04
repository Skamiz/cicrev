-- TODO: put constants in thier own file, into the table c
local c_grass = minetest.get_content_id("cicrev:dirt_with_grass")
local c_dirt = minetest.get_content_id("cicrev:soil")
local c_sand = minetest.get_content_id("cicrev:sand")
local c_water = minetest.get_content_id("cicrev:water_source")

minetest.set_mapgen_setting("water_level", "0", true)

--noise parameters
np_generic = {
        offset = 0,
        scale = 1,
        spread = {x = 20, y = 20, z = 20},
        seed = 0,
        octaves = 3,
        persist = 0.63,
        lacunarity = 2.0,
}

local side_lenght = 80
local chunk_size = {x = 80, y = 84, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}
local nobj_generic = get_noise_object(np_generic, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)

    local noise_values_generic_3d = nobj_generic:get_3d_map_flat(minp)

    math.randomseed(blockseed)

	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				local vi = area:index(x, y, z)

                -- TODO: fiure out how to use :index() here
                local noise_value_3d = noise_values_generic_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 1, z - minp.z + 1)]
                local noise_value_3d_1 = noise_values_generic_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 1 + 1, z - minp.z + 1)]
                -- assert(noise_value_3d, (z-minp.z) * side_lenght * side_lenght + (y-minp.y) * side_lenght + x-minp.x + 1)


                if y < 0 then
                    data[vi] = c_water
                end

                if noise_value_3d - y / 20 > 0 then
                    -- data[vi] = c_sand
                    if noise_value_3d_1 - (y + 1) / 20 > 0 then
                        data[vi] = c_dirt
                    end
                end

			end
		end
	end

	vm:set_data(data)
	vm:write_to_map()
end)
