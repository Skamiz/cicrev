-- This is only a test file for a mapgen someone had trubble with in the forums.

local c_bedrock = minetest.get_content_id("cicrev:soil_with_grass")
local c_stone = minetest.get_content_id("df_stones:andesite")
local c_water = minetest.get_content_id("cicrev:water_source")

local planet_eclasia = {
	y_start = 0,
	y_height = 40,
	y_terrain_height = 20,
}

local height_params = {
    offset = 0,
    scale = 10,
    spread = {x = 40, y = 40, z = 40},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
	flags = "noeased",
}

local height_perlin_map = {}

minetest.register_on_generated(function(minp, maxp)
    if minp.y < planet_eclasia.y_start or minp.y > (planet_eclasia.y_start + planet_eclasia.y_height) then
        -- return
    end

    local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()

    local side_length = maxp.x - minp.x + 1
	local map_lengths_xyz = {x = side_length, y = side_length, z = side_length}

    height_perlin = minetest.get_perlin_map(height_params, map_lengths_xyz)
	height_perlin:get_2d_map_flat({x=minp.x, y=minp.z}, height_perlin_map)

    local perlin_index = 1

    for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local height_perlin_factor = height_perlin_map[perlin_index]
            local terrain_height = planet_eclasia.y_start + height_perlin_factor-- * planet_eclasia.y_terrain_height

            for y = minp.y, maxp.y do
                local index = area:index(x, y, z)
                -- y = y - 55

                if y < planet_eclasia.y_start then
                    data[index] = c_bedrock

                elseif y < terrain_height then
                    data[index] = c_stone

                elseif y < planet_eclasia.y_start + planet_eclasia.y_terrain_height / 3 then
                    data[index] = c_water
                end
            end

            perlin_index = perlin_index + 1
        end
    end

    vm:set_data(data)
    vm:set_lighting({day=15, night=0})
    vm:write_to_map()
end)
