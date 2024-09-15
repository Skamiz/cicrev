local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local name_prefix = modname .. ":"
local texture_prefix = modname .. "_"

local function node_name(name)
	return name_prefix .. name
end
local function texture(name)
	return texture_prefix .. name .. ".png"
end
local function world_tile(name, scale)
	return {name = texture(name), align_style = "world", scale = scale},
end

minetest.register_node(node_name("limestone"), {
	description = "Limestone",
	tiles = {
		world_tile("limestone_2x2", 2)
	},
})
