local island_radius = 30

local c_air = minetest.CONTENT_AIR
local c_stone = minetest.get_content_id("df_stones:limestone")
local c_redstone = minetest.get_content_id("df_stones:rhyolite")
local c_obsidian = minetest.get_content_id("df_stones:obsidian")
local c_lava = minetest.get_content_id("df_stones:gneiss")
local c_grass = minetest.get_content_id("cicrev:soil_with_grass")
local c_dirt = minetest.get_content_id("cicrev:soil")
local c_sand = minetest.get_content_id("cicrev:sand")
local c_gravel = minetest.get_content_id("cicrev:gravel")
local c_water = minetest.get_content_id("cicrev:water_source")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- necesary, otherwise it breaks things

-- function vector.distance2(a, b)
-- 	local x = a.x - b.x
-- 	local y = a.y - b.y
-- 	local z = a.z - b.z
-- 	return (x * x + y * y + z * z)
-- end
local function dist_to_point2(p, x, y, z)
    return math.sqrt(((p.x - x) * (p.x - x)) + ((p.y - y) * (p.y - y)) + ((p.z - z) * (p.z - z)))
    -- return ((p.x - x) * (p.x - x)) + ((p.y - y) * (p.y - y)) + ((p.z - z) * (p.z - z))
end

local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end

local middle = vector.new(0, 0, 0)
local middle2 = vector.new(0, 20, 0)



--noise parameters
np_3d = {
        offset = 0,
        scale = 10,
        spread = {x = 10, y = 10, z = 10},
        seed = 0,
        octaves = 1,
        persist = 1,
        lacunarity = 1.0,
}

-- np_2d = {
--         offset = 0,
--         scale = 8,
--         spread = {x = 20, y = 20, z = 20},
--         seed = 0,
--         octaves = 3,
--         persist = 0.4,
--         lacunarity = 2.7,
-- 		-- flags = "noeased",
-- }
np_2d = {
        offset = 0,
        scale = 4,
        spread = {x = 20, y = 20, z = 20},
        seed = 0,
        octaves = 3,
        persist = 0.4,
        lacunarity = 2.7,
		-- flags = "noeased",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_3d = nobj_3d:get_3d_map_flat(minp)
    local nvals_2d = nobj_2d:get_2d_map_flat(minp)



    math.randomseed(blockseed)

	for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local dist2 = x*x + z*z
            local height = lerp(5.5, 0, dist2/(100*100))

			local nv_2d = nvals_2d[(z-minp.z) * 80 + (x-minp.x) + 1]
			height = height + nv_2d

            for y = minp.y, maxp.y do
				local vi = area:index(x, y, z)

				local nv_3d = nvals_3d[ni]



                if y <= height then
					if height > 1 then
	                    if y > height - 1 then
	                        data[vi] = c_grass
						elseif y > height - 4 then
							data[vi] = c_dirt
						else
							data[vi] = c_stone
						end
					elseif height > -1 then
						if y > height - 4 then
							data[vi] = c_sand
						else
							data[vi] = c_stone
						end
					else
						if y > height - 1 then
							data[vi] = c_gravel
						else
							data[vi] = c_stone
						end
					end
                end


                if y <= 0 and data[vi] == c_air then
                    data[vi] = c_water
                end

			end
		end
	end

	vm:set_data(data)
	-- vm:update_liquids()
	-- vm:calc_lighting()
	vm:write_to_map()
end)

minetest.register_chatcommand("dist", {
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
        local pos = player:get_pos()

        local d1 = math.sqrt(dist_to_point2(middle, pos.x, pos.y, pos.z))
        local d2 = math.sqrt(dist_to_point2(middle2, pos.x, pos.y, pos.z))
        minetest.chat_send_all(d1 - d2)
        -- minetest.chat_send_all(math.sqrt(dist_to_point2(middle2, pos.x, pos.y, pos.z)))
	end
})
