local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)


local name_prefix = modname .. ":"
local texture_prefix = modname .. "_"

local function item_name(name)
	return name_prefix .. name
end
local function texture(name)
	return texture_prefix .. name .. ".png"
end
local function world_tile(name, scale)
	return {name = texture(name), align_style = "world", scale = scale}
end

minetest.register_node(item_name("native_copper_in_limestone"), {
	description = "Native Copper in Limestone",
	tiles = {
		"c_stone_limestone.png" .. "^" .. texture("native_copper_vein"),
	},
	groups = {ore_vein = 1, copper_ore = 1},
	drop = item_name("ore_native_copper"),
})
minetest.register_node(item_name("native_copper_in_granite"), {
	description = "Native Copper in Granite",
	tiles = {
		"c_stone_granite.png" .. "^" .. texture("native_copper_vein"),
	},
	groups = {ore_vein = 1, copper_ore = 1},
	drop = item_name("ore_native_copper"),
})
minetest.register_node(item_name("native_copper_in_slate"), {
	description = "Native Copper in Slate",
	tiles = {
		"c_stone_slate.png" .. "^" .. texture("native_copper_vein"),
	},
	groups = {ore_vein = 1, copper_ore = 1},
	drop = item_name("ore_native_copper"),
})

minetest.register_node(item_name("hematite_in_limestone"), {
	description = "Hematite in Limestone",
	tiles = {
		"c_stone_limestone.png" .. "^" .. texture("hematite_vein"),
	},
	drop = item_name("ore_hematite"),
})

minetest.register_node(item_name("native_platinum_in_limestone"), {
	description = "Native Platinum in Limestone",
	tiles = {
		"c_stone_limestone.png" .. "^" .. texture("native_platinum_vein"),
	},
	drop = item_name("ore_native_platinum"),
})
minetest.register_node(item_name("native_platinum_in_granite"), {
	description = "Native Platinum in Granite",
	tiles = {
		"c_stone_granite.png" .. "^" .. texture("native_platinum_vein"),
	},
	drop = item_name("ore_native_platinum"),
})
minetest.register_node(item_name("native_platinum_in_slate"), {
	description = "Native Platinum in Slate",
	tiles = {
		"c_stone_slate.png" .. "^" .. texture("native_platinum_vein"),
	},
	drop = item_name("ore_native_platinum"),
})



minetest.register_craftitem(item_name("ore_native_copper"), {
	description = "Native Copper Chunk",
	inventory_image = texture("native_copper_ore"),
})
minetest.register_craftitem(item_name("ore_hematite"), {
	description = "Hematite chunk",
	inventory_image = texture("hematite_ore"),
})
minetest.register_craftitem(item_name("ore_native_platinum"), {
	description = "Native Platinum Nugets",
	inventory_image = texture("native_platinum_ore"),
})

minetest.register_craftitem(item_name("ingot_copper"), {
	description = "Copper Cube",
	inventory_image = texture("copper_ingot"),
})
minetest.register_craftitem(item_name("ingot_iron"), {
	description = "Iron Cube",
	inventory_image = texture("iron_ingot"),
})
minetest.register_craftitem(item_name("ingot_steel"), {
	description = "Steel Cube",
	inventory_image = texture("steel_ingot"),
})
minetest.register_craftitem(item_name("ingot_platinum"), {
	description = "Platinum Cube",
	inventory_image = texture("platinum_ingot"),
})

minetest.register_node(item_name("block_copper"), {
	description = "Copper Block",
	tiles = {
		world_tile("block_copper"),
	},
})
minetest.register_node(item_name("block_iron"), {
	description = "Iron Block",
	tiles = {
		world_tile("block_iron"),
	},
})
minetest.register_node(item_name("block_steel"), {
	description = "Steel Block",
	tiles = {
		world_tile("block_steel"),
	},
})
minetest.register_node(item_name("block_platinum"), {
	description = "Platinum Block",
	tiles = {
		world_tile("block_platinum"),
	},
})


dofile(modpath .. "/recipes.lua")
