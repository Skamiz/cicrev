local c_grass = minetest.get_content_id("cicrev:dirt_with_grass")
local c_dirt = minetest.get_content_id("cicrev:loam")
local c_sand = minetest.get_content_id("cicrev:sand")
local c_water = minetest.get_content_id("cicrev:water_source")

minetest.set_mapgen_setting("water_level", "-6", true)

--noise parameters
np_generic = {
        offset = 0,
        scale = 1,
        spread = {x = 20, y = 20, z = 20},
        seed = 0,
        octaves = 3,
        persist = 0.63,
        lacunarity = 2.0,
        -- flags = "simplex", --doesn't seem to do anything
}

np_hillines = {
        offset = 0,
        scale = 8,
        spread = {x = 100, y = 20, z = 20},
        seed = 1,
        octaves = 3,
        persist = 0.63,
        lacunarity = 2.0,
}

np_tunels = {
        offset = 0,
        scale = 1,
        spread = {x = 40, y = 200, z = 200},
        seed = 1,
        octaves = 1,
        persist = 0.63,
        lacunarity = 2.0,
}

local y_offset = 10 --base terain height offset
local y_scale = 70
local clif_height = 30
local cliff_width = 2 -- depends on noise scale

local nobj_generic = nil
local nobj_hillines = nil
local nobj_tunels = nil

local data = {}
local noise_values_generic_2d = {}
local noise_values_generic_3d = {}
local nvals_tunels = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)

	local side_lenght = maxp.x - minp.x + 1
	local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}

    nobj_generic = nobj_generic or minetest.get_perlin_map(np_generic, chunk_size)
    nobj_hillines = nobj_hillines or minetest.get_perlin_map(np_hillines, chunk_size)
    nobj_tunels = nobj_tunels or minetest.get_perlin_map(np_tunels, chunk_size)

	nobj_hillines:get_2d_map_flat({x = minp.x, y = minp.z}, noise_values_generic_2d)
    nobj_generic:get_3d_map_flat({x = minp.x, y = minp.y, z = minp.z}, noise_values_generic_3d)
    nobj_tunels:get_2d_map_flat({x = minp.x, y = minp.z}, nvals_tunels)

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

                local noise_value = noise_values_generic_2d[(z-minp.z) * chunk_size.x + x-minp.x + 1]
                local nval_tunels = nvals_tunels[(z-minp.z) * chunk_size.x + x-minp.x + 1]
                local noise_value_3d = noise_values_generic_3d[(z-minp.z) * side_lenght * side_lenght + (y-minp.y) * side_lenght + x-minp.x + 1]
                assert(noise_value_3d, (z-minp.z) * side_lenght * side_lenght + (y-minp.y) * side_lenght + x-minp.x + 1)
                assert(noise_value, (z-minp.z) * chunk_size.x + x-minp.x)

                if noise_value_3d > maxv then
                    maxv = noise_value_3d
                elseif noise_value_3d < minv then
                    minv = noise_value_3d
                end

                if y < -6 then
                        data[vi] = c_water
                end

                if noise_value > cliff_width  and noise_value - (y - clif_height) > 0 then
                    data[vi] = stone

                    if noise_value - (y - clif_height) < 0.8 then
                        data[vi] = c_sand
                    end
                elseif noise_value < cliff_width and noise_value - y > 0 then
                    data[vi] = stone

                    if noise_value - y < 2.5 then
                        data[vi] = c_dirt
                    end
                    if noise_value - y < 1 then
                        data[vi] = c_grass
                    end
                end
                if noise_value > 0 and noise_value < cliff_width then
                    if noise_value - (y - clif_height) > 0 and noise_value_3d + (((noise_value / cliff_width) * 2) - (noise_value / cliff_width)) > 0 then
                        data[vi] = stone
                    end
                end
                -- if nval_tunels < 0.1 and nval_tunels > -0.1  and y > 0 and y < 5 then
                --     data[vi] = minetest.CONTENT_AIR
                -- end
                if math.abs((y - 3) * nval_tunels) < 0.08 and nval_tunels < 0.1 and nval_tunels > -0.1  and y > 0 and y < 5 then
                    data[vi] = minetest.CONTENT_AIR
                end
			end
		end
	end

    -- minetest.chat_send_all("minp is: " .. minetest.pos_to_string(minp) .. "; maxp is: " .. minetest.pos_to_string(maxp))

	vm:set_data(data)
    minetest.generate_decorations(vm)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:write_to_map(data)

end)
