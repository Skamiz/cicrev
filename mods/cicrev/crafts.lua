minetest.register_craft({
    output = "cicrev:planks_dark 4",
    recipe = {
        {"cicrev:log_dark"},
    },
})

minetest.register_craft({
    output = "cicrev:stick 2",
    recipe = {
        {"group:planks"},
    },
})

minetest.register_craft({
    output = "cicrev:knife_flint",
    recipe = {
		{"cicrev:knife_head_flint"},
		{"cicrev:stick"},
	},
})

minetest.register_craft({
    output = "cicrev:axe_flint",
    recipe = {
		{"cicrev:axe_head_flint"},
		{"cicrev:stick"},
    },
})

minetest.register_craft({
	output = "cicrev:mallet_wood",
	recipe = {
		{"group:log"},
		{"group:stick"},
		{"group:stick"},
	}
})

minetest.register_craft({
    output = "cicrev:crate",
    recipe = {
        {"group:plank", "group:plank", "group:plank"},
        {"group:plank", "", 			 "group:plank"},
        {"group:plank", "group:plank", "group:plank"},
    },
})

minetest.register_craft({
    output = "cicrev:grass_rope",
    recipe = {
        {"", "", "cicrev:grass"},
        {"", "cicrev:grass", "cicrev:grass"},
        {"cicrev:grass", "cicrev:grass", ""},
    },
})
minetest.register_craft({
    output = "cicrev:thatch",
    recipe = {
        {"cicrev:grass", "cicrev:grass", "cicrev:grass"},
        {"cicrev:grass", "cicrev:grass", "cicrev:grass"},
        {"cicrev:grass", "cicrev:grass", "cicrev:grass"},
    },
})
minetest.register_craft({
    output = "cicrev:grass 9",
    recipe = {
        {"cicrev:thatch"},
    },
})

minetest.register_craft({
    output = "cicrev:ladder",
    recipe = {
        {"cicrev:stick", "cicrev:grass_rope", "cicrev:stick"},
        {"cicrev:stick", "cicrev:stick", "cicrev:stick"},
        {"cicrev:stick", "cicrev:grass_rope", "cicrev:stick"},
    },
})

minetest.register_craft({
    output = "cicrev:flint",
    recipe = {
        {"cicrev:gravel"},
    },
})

minetest.register_craft({
    output = "cicrev:fire_stones",
    recipe = {
        {"", "df_stones:chert_rock"},
        {"df_stones:chert_rock", ""},
    },
})

minetest.register_craft({
    output = "cicrev:campfire",
    recipe = {
        {"group:plank", "cicrev:stick", "group:plank"},
        {"cicrev:stick", "cicrev:thatch", "cicrev:stick"},
        {"group:plank", "cicrev:stick", "group:plank"},
    },
})

minetest.register_craft({
	output = "cicrev:digging_stick",
	recipe = {
		{"", "", "group:stick"},
		{"cicrev:grass_rope", "group:stick", ""},
		{"group:stick", "", ""},
	}
})

-- knapping

knapping.register_recipe({
	input = "cicrev:flint",
	output = "cicrev:knife_head_flint",
	recipe = {
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 1, 0, 0},
		{0, 0, 0, 0, 1, 1, 0, 0},
		{0, 0, 0, 1, 1, 0, 0, 0},
		{0, 0, 1, 1, 1, 0, 0, 0},
		{0, 0, 1, 1, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
	},
	texture = "df_stones_chert.png",
})
knapping.register_recipe({
	input = "cicrev:flint",
	output = "cicrev:axe_head_flint",
	recipe = {
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 1, 1, 1, 0, 0},
		{0, 0, 1, 1, 1, 1, 0, 0},
		{0, 1, 1, 1, 1, 1, 0, 0},
		{0, 1, 1, 1, 1, 1, 1, 0},
		{0, 1, 1, 1, 1, 1, 0, 0},
		{0, 0, 0, 0, 1, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
	},
	texture = "df_stones_chert.png",
})
knapping.register_recipe({
	input = "cicrev:flint",
	output = "cicrev:rune_speed",
	recipe = {
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 1, 1, 1, 1, 0, 0},
		{0, 1, 1, 1, 0, 1, 1, 0},
		{0, 1, 1, 0, 1, 1, 1, 0},
		{0, 1, 0, 1, 1, 0, 1, 0},
		{0, 1, 1, 1, 0, 1, 1, 0},
		{0, 0, 1, 1, 1, 1, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
	},
	texture = "df_stones_chert.png",
})

knapping.register_recipe({
	input = "df_stones:chert_rock",
	output = "cicrev:knife_head_flint",
	recipe = {
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 1, 0, 0},
		{0, 0, 0, 0, 1, 1, 0, 0},
		{0, 0, 0, 1, 1, 0, 0, 0},
		{0, 0, 1, 1, 1, 0, 0, 0},
		{0, 0, 1, 1, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
	},
	texture = "df_stones_chert.png",
})
knapping.register_recipe({
	input = "df_stones:chert_rock",
	output = "cicrev:axe_head_flint",
	recipe = {
		{0, 0, 0, 0, 0, 0, 0, 0},
		{0, 0, 0, 1, 1, 1, 0, 0},
		{0, 0, 1, 1, 1, 1, 0, 0},
		{0, 1, 1, 1, 1, 1, 0, 0},
		{0, 1, 1, 1, 1, 1, 1, 0},
		{0, 1, 1, 1, 1, 1, 0, 0},
		{0, 0, 0, 0, 1, 0, 0, 0},
		{0, 0, 0, 0, 0, 0, 0, 0},
	},
	texture = "df_stones_chert.png",
})
