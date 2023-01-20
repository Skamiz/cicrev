local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- minetest.register_biome({
-- 	name = "tundra",
-- 	node_top = "cicrev:soil_with_grass",
-- 	depth_top = 1,
-- 	heat_point = 50,
-- 	humidity_point = 50,
-- })
minetest.register_biome({
	name = "winter",
	node_dust = "cicrev:snow_layer",
	node_top = "cicrev:soil_with_snow",
	depth_top = 1,
	node_filler = "cicrev:soil",
    depth_filler = 2,
	node_stone = "df_stones:dolomite",
	node_water_top = "cicrev:ice",
	heat_point = 50,
	humidity_point = 50,
	y_min = 0,
})
minetest.register_biome({
	name = "underground",
	-- node_dust = "cicrev:snow_layer",
	-- node_top = "cicrev:soil_with_snow",
	-- depth_top = 1,
	node_filler = "cicrev:soil",
    depth_filler = 2,
	-- node_stone = "df_stones:dolomite",
	-- node_water_top = "cicrev:ice",
	-- heat_point = 50,
	-- humidity_point = 50,
	y_max = -1,
})

-- minetest.register_biome({
-- 	name = "sand",
-- 	node_top = "cicrev:sand_with_grass",
-- 	heat_point = 50,
-- 	humidity_point = 50,0
-- })

-- local s = minetest.read_schematic("schematics/tree_oak.mts", "all")
minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:dirt_with_grass",
	y_min = 0,
    y_max = 50,
	fill_ratio = 0.001,
	schematic = modpath .. "/schematics/tree_oak.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:soil_with_snow",
	y_min = 0,
    y_max = 50,
	fill_ratio = 0.01,
	schematic = modpath .. "/schematics/tree_dark_snowy.mts",
	rotation = "random",
	flags = "place_center_x, place_center_z",
	place_offset_y = 1,
})

-- minetest.register_decoration({
-- 	deco_type = "schematic",
-- 	place_on = "cicrev:dirt_with_grass",
-- 	y_min = 0,
--     y_max = 50,
-- 	fill_ratio = 0.001,
-- 	schematic = "schematics/tree_dark.mts",
-- 	flags = "place_center_x, place_center_z",
-- 	place_offset_y = 1,
-- })
--
-- minetest.register_decoration({
-- 	deco_type = "schematic",
-- 	place_on = "cicrev:dirt_with_grass",
-- 	y_min = 0,
--     y_max = 50,
-- 	fill_ratio = 0.001,
-- 	schematic = "schematics/tree_chaktekok.mts",
-- 	flags = "place_center_x, place_center_z",
-- 	place_offset_y = 1,
-- })
--
-- minetest.register_decoration({
-- 	deco_type = "schematic",
-- 	place_on = "cicrev:dirt_with_grass",
-- 	y_min = 0,
--     y_max = 50,
-- 	fill_ratio = 0.001,
-- 	schematic = "schematics/tree_chestnut.mts",
-- 	flags = "place_center_x, place_center_z",
-- 	place_offset_y = 1,
-- })


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

minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:peat_with_moss",
	y_min = 0,
    y_max = 0,
    param2 = 32,
    param2_max = 35,
	fill_ratio = 0.6,
	decoration = {"cicrev:sawgrass"},
	-- flags = "place_center_x, place_center_z",
})
minetest.register_decoration({
	deco_type = "simple",
	place_on = "cicrev:peat_with_moss",
	y_min = 0,
    y_max = 0,
    param2 = 32,
    param2_max = 34,
	fill_ratio = 0.6,
	decoration = {"cicrev:sedge"},
	-- flags = "place_center_x, place_center_z",
})
