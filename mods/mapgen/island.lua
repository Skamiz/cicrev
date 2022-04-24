local island_radius = 100

local c_air = minetest.CONTENT_AIR
local c_stone = minetest.get_content_id("df_stones:limestone")
local c_redstone = minetest.get_content_id("df_stones:rhyolite")
local c_chert = minetest.get_content_id("df_stones:chert")
local c_obsidian = minetest.get_content_id("df_stones:obsidian")
local c_lava = minetest.get_content_id("df_stones:gneiss")
local c_grass = minetest.get_content_id("cicrev:soil_with_grass")
local c_dirt = minetest.get_content_id("cicrev:soil")
local c_sand = minetest.get_content_id("cicrev:sand")
local c_clay = minetest.get_content_id("cicrev:clay")
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

-- direction in which the shell oopens
local shell_dir = vector.new(-1, 3, 0):normalize()
local hill_pos = {x = -40, z = -90}


--noise parameters
np_3d = {
        offset = 0,
        scale = 1,
        spread = {x = 10, y = 10, z = 10},
        seed = 0,
        octaves = 2,
        persist = 0.4,
        lacunarity = 1.6,
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

np_2d_jut = {
        offset = 0,
        scale = 4,
        spread = {x = 8, y = 8, z = 8},
        seed = 0,
        octaves = 1,
        persist = 1,
        lacunarity = 1,
		flags = "noeased, absvalue",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)
local nobj_2d_j = noise_handler.get_noise_object(np_2d_jut, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_3d = nobj_3d:get_3d_map_flat(minp)
    local nvals_2d = nobj_2d:get_2d_map_flat(minp)
    local nvals_2d_j = nobj_2d_j:get_2d_map_flat(minp)



    math.randomseed(blockseed)

	for z = minp.z, maxp.z do
        for x = minp.x, maxp.x do
            local dist2 = x*x + z*z
            local height = lerp(5.5, 0, dist2/(island_radius*island_radius))

			local nv_j = nvals_2d_j[(z-minp.z) * 80 + (x-minp.x) + 1]

			local nv_2d = nvals_2d[(z-minp.z) * 80 + (x-minp.x) + 1]
			height = height + nv_2d

			local hill_dist = math.pow(hill_pos.x - x, 2) + math.pow(hill_pos.z - z, 2)
			if hill_dist < 60*60 then
				height = lerp(height, height + 20, 1 - hill_dist/(60*60))
			end

            for y = minp.y, maxp.y do
				local vi = area:index(x, y, z)

				local nv_3d = nvals_3d[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]



                if y <= height then
					if hill_dist < 60*60 and height > 16 - nv_2d*1.1 then
						-- if y > 16 then
						   data[vi] = c_chert
						-- end
					elseif math.pow(-40 - x, 2) + math.pow(80 - z, 2) + math.pow(nv_2d, 2)*100 <= 40*40 then
						if height <= -1 then
							if y > height - 2 then
								data[vi] = c_clay
							else
								data[vi] = c_stone
							end
						else
							if y > height - 4 then
								data[vi] = c_sand
							elseif y > height - 6 then
								data[vi] = c_clay
							else
								data[vi] = c_stone
							end
						end
					elseif height >= 0 and height <= 1 then
						if y > height - 4 then
							data[vi] = c_sand
						else
							data[vi] = c_stone
						end
					elseif height > 1 then
	                    if y > height - 1 then
	                        data[vi] = c_grass
						elseif y > height - 4 then
							data[vi] = c_dirt
						else
							data[vi] = c_stone
						end
					else
						if y > height - 1 then
							-- TODO: if clse to island place clay
							data[vi] = c_gravel
						else
							data[vi] = c_stone
						end
					end
                end


                if y <= 0 and data[vi] == c_air then
                    data[vi] = c_water
                end

				-- TODO: try to use a 2d noise for the pilars instead

				local dist3 = x*x + y*y + z*z
				-- distance along shell_dir axis
				local dist_ax = x * shell_dir.x + y * shell_dir.y + z * shell_dir.z

				-- local density = math.abs(dist2/(145*145) - 1) * -145  + 10
				local density = math.min(math.abs(dist2/(145*145) - 1) * -145  + 10, 0)
				-- density = density - (dist_ax/10 + 10)
				-- density = density - y/8
				-- density = math.min(density - (dist_ax/10 + 10), density - y/8)
				density = density + nv_j - 2
				density = density + nv_3d

				if dist_ax > -5 then
					density = density - (dist_ax + 5)
				end

				if y < 0 then
					density = density + math.pow(y/3, 2)
				end

				if true
				and density > 0
				-- and dist_ax <= 0
				-- and y < 10
				-- and nv_j > 2
				then
            		data[vi] = c_stone
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

        minetest.chat_send_all("foo")
	end
})
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:soil_with_grass",
    y_min = 3,
    y_max = 7,
	fill_ratio = 0.008,
	rotation = "random",
	schematic = "schematics/tree_chaktekok.mts",
	flags = "place_center_x, place_center_z, force_placement",
	place_offset_y = 1,
})
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:soil_with_grass",
    y_min = 8,
    y_max = 14,
	fill_ratio = 0.003,
	rotation = "random",
	schematic = "schematics/tree_dark.mts",
	flags = "place_center_x, place_center_z, force_placement",
	place_offset_y = 1,
})
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:soil_with_grass",
    y_min = 1,
    y_max = 3,
	fill_ratio = 0.001,
	rotation = "random",
	schematic = "schematics/tree_chestnut.mts",
	flags = "place_center_x, place_center_z, force_placement",
	place_offset_y = 1,
})
minetest.register_decoration({
	deco_type = "simple",
	place_on = "df_stones:chert",
	y_min = 10,
    y_max = 40,
	fill_ratio = 0.1,
	decoration = {"df_stones:chert_rock"},
	-- flags = "place_center_x, place_center_z",
})
minetest.register_ore({
	ore_type = "scatter",
	ore = "cicrev:tetrahedrite",
	wherein = "df_stones:limestone",
	clust_scarcity = 5 * 5 * 5,
	clust_num_ores = 5,
	clust_size = 2,
	y_min = 2,
    y_max = 150,
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:dirt_with_grass",
	y_min = 0,
    y_max = 50,
    param2 = 0,
    param2_max = 45,
	fill_ratio = 0.3,
	decoration = {"cicrev:tall_grass_1", "cicrev:tall_grass_2", "cicrev:tall_grass_3"},
	-- flags = "place_center_x, place_center_z",
})
