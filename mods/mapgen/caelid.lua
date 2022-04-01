local c_air = minetest.CONTENT_AIR
local c_dirt = minetest.get_content_id("cicrev:silt")
local c_grass = minetest.get_content_id("cicrev:silt_with_fungus")
local c_stone = minetest.get_content_id("df_stones:rhyolite")
local c_intrude = minetest.get_content_id("cicrev:clay")
local c_ring = minetest.get_content_id("df_stones:obsidian")
local c_ring_i = minetest.get_content_id("cicrev:corite")

minetest.set_mapgen_setting("water_level", "0", true)

-- TODO: move rings to their own file

local depth = 25
local surface_limit = 0.1
local botom_limit = 0.15


local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end



--noise parameters
-- base terrain height
np_2d_base = {
    offset = 0,
    scale = 7,
    spread = {x = 80, y = 80, z = 80},
    seed = 0,
    octaves = 3,
    persist = 0.5,
    lacunarity = 3,
	-- flags = "noeased",
}
-- mountains
np_2d_alt = {
    offset = 0-50,
    scale = 100,
    spread = {x = 200, y = 200, z = 200},
    seed = 5,
    octaves = 1,
    persist = 0.1,
    lacunarity = 50,
	flags = "absvalue",
}
-- distribution of the canyons
np_2d_crag = {
    offset = 0,
    scale = 1,
    spread = {x = 40, y = 40, z = 40},
    seed = 1,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
	flags = "absvalue",
}
-- distribution of the web
np_3d_intrude = {
    offset = 0,
    scale = 1,
    spread = {x = 30, y = 30, z = 30},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
    flags = "absvalue",
}
-- cracks in the shells of the great rings
np_3d_ring = {
    offset = 0,
    scale = 1,
    spread = {x = 8, y = 8, z = 8},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
    -- flags = "absvalue",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_2d_b = noise_handler.get_noise_object(np_2d_base, chunk_size)
local nobj_2d_c = noise_handler.get_noise_object(np_2d_crag, chunk_size)
local nobj_2d_a = noise_handler.get_noise_object(np_2d_alt, chunk_size)
local nobj_3d_i = noise_handler.get_noise_object(np_3d_intrude, chunk_size)
local nobj_3d_r = noise_handler.get_noise_object(np_3d_ring, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	if maxp.y < 0 or minp.y > 80 then return end
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_2d_b = nobj_2d_b:get_2d_map_flat(minp)
    local nvals_2d_c = nobj_2d_c:get_2d_map_flat(minp)
    local nvals_2d_a = nobj_2d_a:get_2d_map_flat(minp)
    local nvals_3d_i = nobj_3d_i:get_3d_map_flat(minp)
	local nvals_3d_r


    math.randomseed(blockseed)

	local rdir, rpos
	if math.random() < 1/25 then
		nvals_3d_r = nobj_3d_r:get_3d_map_flat(minp)
		rdir = vector.new(math.random() - 0.5, (math.random() - 0.5)/2, math.random() - 0.5):normalize()
		rpos = {}
		-- vector.new(math.floor((minp.x + maxp.x) / 2),
		-- 		math.floor((minp.z + maxp.z) / 2),
		-- 		math.floor(nvals_2d_b[(ring_z-minp.z) * 80 + (ring_x-minp.x) + 1]))
		rpos.x = math.floor((minp.x + maxp.x) / 2)
		rpos.z = math.floor((minp.z + maxp.z) / 2)
		rpos.y = math.floor(nvals_2d_b[(rpos.z-minp.z) * 80 + (rpos.x-minp.x) + 1])
	end

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)

                local nv_2d_b = nvals_2d_b[(z-minp.z) * 80 + (x-minp.x) + 1]
                local nv_2d_c = nvals_2d_c[(z-minp.z) * 80 + (x-minp.x) + 1]
                local nv_2d_a = nvals_2d_a[(z-minp.z) * 80 + (x-minp.x) + 1] + nv_2d_b
                local nv_3d_i = nvals_3d_i[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]

				ni = ni + 1

				local surface = math.max(nv_2d_b, nv_2d_a)
				local bottom = math.max(nv_2d_b - depth, nv_2d_a)

				if surface > y then
					data[vi] = c_grass
				end

				if surface - 1 > y then
					data[vi] = c_stone
				end

                if nv_2d_c < math.max(surface_limit, botom_limit) and bottom < surface then
                    if bottom < y and surface > y then
                        local limit = lerp(surface_limit, botom_limit, (nv_2d_b - y)/depth)
                        if nv_2d_c < limit then
                            data[vi] = c_air
                        end
                    end
                    if bottom > y and bottom < y + 1  and nv_2d_c < botom_limit then
                        data[vi] = c_dirt
                        if nv_2d_c < botom_limit - 0.05 then
                            data[vi] = c_grass
                        end
                    end
                end

				-- intrusion
                if nv_3d_i < 0.02 then
                    if surface + 1 > y then
                        local limit = lerp(surface_limit, botom_limit, (nv_2d_b - y)/depth)
                        if nv_2d_c > limit - 0.02 or nv_2d_b + 1.5 - depth > y then
                            if data[vi] == c_air then
                                data[vi] = c_intrude
                            end
                        end
    				end
				end

				-- ring
				if rdir then
					local dist = math.pow(rpos.x - x, 2) + math.pow(rpos.z - z, 2) + math.pow(rpos.y - y, 2)
					if dist > math.pow(31, 2) and dist < math.pow(34, 2) and
					 	math.abs((x-rpos.x) * rdir.x + (y-rpos.y) * rdir.y + (z-rpos.z) * rdir.z) <= 2 then
						data[vi] = c_ring_i
					end
					local nv_3d_r = nvals_3d_r[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]

					if data[vi] ~= c_ring_i and nv_3d_r < 0.3 and
							dist > math.pow(30, 2) and dist < math.pow(35, 2) and
						 	math.abs((x-rpos.x) * rdir.x + (y-rpos.y) * rdir.y + (z-rpos.z) * rdir.z) <= 3 then
						data[vi] = c_ring
					end
				end

			end
		end
	end

	vm:set_data(data)
	minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
	-- only necessary if corite doesn't have paramtype = light
	-- if rdir then
	-- 	minetest.fix_light(minp, maxp)
	-- end
end)


-- SKY
minetest.register_on_joinplayer(
    function(player)
        player:set_sky({
            type = "regular",
            -- base_color = "#a45037",
            clouds = true,
            sky_color = {
                day_sky = "#d53a39",
                day_horizon = "#b3594d",
                dawn_sky = "#c8776c",
                dawn_horizon = "#fbaf8e",
                night_sky = "#232943",
                night_horizon = "#323c51",
            },
            player:set_clouds({
                density = 0.6,
                color = "#722b30",
                ambient = "#1c080a",
            })
        })
    end
)

-- OVERRIDES
minetest.override_item("df_stones:chert_rock", {
	drop = "cicrev:flint",
})

-- DECORATIONS
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:clay",
    y_min = 20,
    y_max = 80,
	fill_ratio = 0.01,
	schematic = "schematics/bloom.mts",
	-- schematic = u.get_sphere_schematic(5, {name = "cicrev:bark_chaktekok"}),
	flags = "place_center_x, place_center_z, force_placement",
	place_offset_y = -2,
})
-- TODO: use gennotify to spread some intrusion around the bloom

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:silt_with_fungus",
	y_min = 0,
    y_max = 50,
	fill_ratio = 0.0001,
	schematic = "schematics/tree_dry_3.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
	place_offset_y = 1,
})
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:silt_with_fungus",
	y_min = -10,
    y_max = 50,
	fill_ratio = 0.001,
	schematic = "schematics/tree_dry_2.mts",
	flags = "place_center_x, place_center_z",
	place_offset_y = 1,
})
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:silt_with_fungus",
	y_min = -80,
    y_max = 50,
	fill_ratio = 0.0005,
	schematic = "schematics/tree_dry_1.mts",
	flags = "place_center_x, place_center_z",
	rotation = "random",
	place_offset_y = 1,
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:silt_with_fungus",
    y_min = -80,
    y_max = 30,
	fill_ratio = 0.001,
	schematic = "schematics/boulder.mts",
	flags = "place_center_x, place_center_z, place_center_y, force_placement",
	place_offset_y = 1,
	rotation = "random",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:silt_with_fungus",
	y_min = -80,
    y_max = 80,
    -- param2 = 32,
    -- param2_max = 34,
	fill_ratio = 0.003,
	decoration = {"cicrev:log_stripped_chestnut"},
    height = 3,
    height_max = 8,
	-- flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:silt_with_fungus",
	y_min = -80,
    y_max = 50,
    param2 = 0,
    param2_max = 3,
	fill_ratio = 0.1,
	decoration = {"df_stones:rhyolite_rock"},
	-- flags = "place_center_x, place_center_z",
})
minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:silt_with_fungus",
	y_min = -80,
    y_max = 5,
	fill_ratio = 0.001,
	decoration = {"df_stones:chert_rock"},
	-- flags = "place_center_x, place_center_z",
})
minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:silt",
	y_min = -80,
    y_max = 5,
	fill_ratio = 0.1,
	decoration = {"df_stones:chert_rock"},
	-- flags = "place_center_x, place_center_z",
})
minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:silt_with_fungus",
	y_min = -80,
    y_max = 20,
	fill_ratio = 0.01,
	decoration = {"cicrev:dry_shrub"},
	-- flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:silt_with_fungus",
	y_min = -80,
    y_max = 50,
    param2 = 0,
    param2_max = 45,
	fill_ratio = 0.7,
	decoration = {"cicrev:tall_grass_dry_1", "cicrev:tall_grass_dry_2", "cicrev:tall_grass_dry_3"},
	-- flags = "place_center_x, place_center_z",
})
minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:silt_with_fungus",
	y_min = -10,
    y_max = 80,
    sidelen = 4,
    param2 = 32,
    param2_max = 35,
	fill_ratio = 0.6,
	decoration = {"cicrev:sawgrass_dry"},
    noise_params = {
        offset = -0.25,
        scale = 0.8,
        spread = {x = 16, y = 16, z = 16},
        seed = 354,
        octaves = 1,
        persistence = 0.7,
        lacunarity = 2.0,
        -- flags = "absvalue"
    },
	-- flags = "place_center_x, place_center_z",
})
-- TODO: shrooms growing on intrusion
