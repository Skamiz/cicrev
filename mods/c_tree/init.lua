local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
-- dofile(modpath .. "/foo.lua")

local name_prefix = modname .. ":"
local texture_prefix = modname .. "_"

local function node_name(name)
	return name_prefix .. name
end
local function texture(name)
	return texture_prefix .. name .. ".png"
end
local function world_tile(name, scale)
	return {name = texture(name), align_style = "world", scale = scale or 1}
end


minetest.register_node(node_name("oak_planks"), {
	description = "Oak Planks",
	tiles = {
		texture("oak_planks"),
	},
})
minetest.register_node(node_name("pine_planks"), {
	description = "Pine Planks",
	tiles = {
		texture("pine_planks"),
	},
})
minetest.register_node(node_name("other_planks"), {
	description = "Other Planks",
	tiles = {
		texture("other_planks"),
	},
})
