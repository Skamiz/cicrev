minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:dirt_with_grass",
	y_min = 0,
    y_max = 50,
	fill_ratio = 0.001,
	schematic = "schematics/tree_oak.mts",
	flags = "place_center_x, place_center_z",
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:dirt_with_grass",
	y_min = 0,
    y_max = 50,
	fill_ratio = 0.001,
	schematic = "schematics/tree_dark.mts",
	flags = "place_center_x, place_center_z",
	place_offset_y = 1,
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:dirt_with_grass",
	y_min = 0,
    y_max = 50,
	fill_ratio = 0.001,
	schematic = "schematics/tree_chaktekok.mts",
	flags = "place_center_x, place_center_z",
	place_offset_y = 1,
})

minetest.register_decoration({
	deco_type = "schematic",
	place_on = "cicrev:dirt_with_grass",
	y_min = 0,
    y_max = 50,
	fill_ratio = 0.001,
	schematic = "schematics/tree_chestnut.mts",
	flags = "place_center_x, place_center_z",
	place_offset_y = 1,
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
