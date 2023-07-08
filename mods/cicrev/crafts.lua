
-- fast_craft.register_craft({
-- 	output = {
-- 		item = "item_out",
-- 		count = n,
-- 	},
-- 	additional_output = {
-- 		["ao_1"] = 1
-- 	},
-- 	input = {
-- 		["item_in_a"] = 1,
--
-- 	},
-- 	condition = function(player),
-- })

-- tools
fast_craft.register_craft({
	output = {"cicrev:knife_flint"},
	input = {
		["cicrev:knife_head_flint"] = 1,
		["group:tool_handle"] = 1,
	},
})
fast_craft.register_craft({
	output = {"cicrev:axe_flint"},
	input = {
		["cicrev:axe_head_flint"] = 1,
		["group:tool_handle"] = 1,
	},
})
fast_craft.register_craft({
	output = {"cicrev:mallet_wood"},
	input = {
		["group:log"] = 1,
		["group:tool_handle"] = 1,
	},
})
fast_craft.register_craft({
	output = {"cicrev:pickaxe_copper"},
	input = {
		["cicrev:ingot_copper"] = 5,
		["group:tool_handle"] = 1,
	},
})
fast_craft.register_craft({
	output = {"cicrev:ingot_copper"},
	input = {
		["cicrev:ore_native_copper"] = 5,
	},
	condition = function(player)
		local pos = player:get_pos()
		return minetest.find_node_near(pos, 3, "cicrev:kiln", true)
	end,
})

fast_craft.register_craft({
	output = {"cicrev:kiln"},
	input = {
		["cicrev:brick"] = 8,
	},
})

fast_craft.register_craft({
	output = {"cicrev:crate"},
	input = {
		["group:plank"] = 8,
	},
})

fast_craft.register_craft({
	output = {"cicrev:grass_rope"},
	input = {
		["cicrev:grass"] = 5,
	},
})
fast_craft.register_craft({
	output = {"cicrev:thatch"},
	input = {
		["cicrev:grass"] = 9,
	},
})
fast_craft.register_craft({
	output = {"cicrev:grass", 9},
	input = {
		["cicrev:thatch"] = 1,
	},
})

fast_craft.register_craft({
	output = {"cicrev:ladder"},
	input = {
		["cicrev:stick"] = 3,
		["cicrev:grass_rope"] = 2,
	},
})

fast_craft.register_craft({
	output = {"cicrev:flint"},
	input = {
		["cicrev:gravel"] = 1,
	},
})

fast_craft.register_craft({
	output = {"cicrev:fire_stones"},
	input = {
		["df_stones:chert_rock"] = 2,
	},
})
fast_craft.register_craft({
	output = {"cicrev:campfire"},
	input = {
		["cicrev:thatch"] = 1,
		["group:plank"] = 4,
		["cicrev:stick"] = 4,
	},
})

fast_craft.register_craft({
	output = {"cicrev:digging_stick"},
	input = {
		["cicrev:grass_rope"] = 1,
		["cicrev:stick"] = 3,
	},
})
fast_craft.register_craft({
	output = {"cicrev:bricks"},
	input = {
		["cicrev:brick"] = 8,
	},
})
fast_craft.register_craft({
	output = {"cicrev:brick_mold"},
	input = {
		["group:plank"] = 6,
	},
})
fast_craft.register_craft({
	output = {"cicrev:clay_lump", 2},
	input = {
		["cicrev:clay"] = 1,
	},
	condition = function(player)
		local p_pos = player:get_pos():round()
	    p_pos.y = p_pos.y + 1

		return minetest.find_node_near(p_pos, 3, {"group:water"}, true)
	end
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
