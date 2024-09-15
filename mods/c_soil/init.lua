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
	return {name = texture(name), align_style = "world", scale = scale}
end

local function register_soils()
	minetest.register_node(node_name("sand"), {
		description = "Sand",
		tiles = {
			texture("sand"),
		},
	})
	shapes.register.quaters(node_name("sand"), {
		description = "Sand",
		tiles = {
			world_tile("sand"),
		},
	})
	minetest.register_node(node_name("clay"), {
		description = "Clay",
		tiles = {
			texture("clay"),
		},
	})

	minetest.register_node(node_name("soil"), {
		description = "Soil",
		tiles = {
			texture("soil"),
		},
	})
	minetest.register_node(node_name("grass"), {
		description = "Grass",
		tiles = {
			texture("grass"),
		},
	})
	minetest.register_node(node_name("soil_with_grass"), {
		description = "Grass on Soil",
		tiles = {
			texture("grass"),
			texture("soil"),
			texture("soil") .. "^" .. texture("grass_side"),
		},
	})
	shapes.register.quaters(node_name("soil_with_grass"), {
		description = "Grass",
		tiles = {
			world_tile("grass"),
		},
	})
end
register_soils()
