local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

-- dofile(modpath .. "/limestone.lua")

local shape_nodes = false
if minetest.global_exists("shapes") then
	shape_nodes = true
end


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

local stone_types = {"Limestone", "Granite", "Slate"}

local function register_stone_type(name, description)
	local stone_name = node_name(name)
	local stone_def = {
		description = description,
		tiles = {
			world_tile(name),
		},
	}
	local block_name = node_name(name) .. "_block"
	local block_def = {
		description = description .. " Block",
		tiles = {
			world_tile(name .. "_block"),
		},
	}
	local bricks_name = node_name(name) .. "_bricks"
	local bricks_def = {
		description = description .. " Bricks",
		tiles = {
			world_tile(name .. "_bricks"),
		},
	}
	local cobble_name = node_name(name) .. "_cobble"
	local cobble_def = {
		description = description .. " Cobble",
		tiles = {
			world_tile(name .. "_cobble"),
		},
	}
	minetest.register_node(stone_name, stone_def)
	minetest.register_node(block_name, block_def)
	minetest.register_node(bricks_name, bricks_def)
	minetest.register_node(cobble_name, cobble_def)

	if shape_nodes then
		shapes.register.quaters(stone_name, stone_def)
		shapes.register.quaters(block_name, block_def)
		shapes.register.quaters(bricks_name, bricks_def)
		shapes.register.quaters(cobble_name, cobble_def)

		shapes.register.wall(bricks_name .. "_wall", bricks_def)
	end
end

for _, stone_type in ipairs(stone_types) do
	register_stone_type(stone_type:lower(), stone_type)
end

-- local function register_stones()
-- 	for _, description in ipairs(stone_types) do
-- 		local stone_type = description:lower()
--
-- 		minetest.register_node(node_name(stone_type), {
-- 			description = description,
-- 			tiles = {
-- 				texture(stone_type)
-- 			},
-- 		})
-- 		minetest.register_node(node_name(stone_type .. "_block"), {
-- 			description = description .. " Block",
-- 			tiles = {
-- 				texture(stone_type .. "_block")
-- 			},
-- 		})
-- 		minetest.register_node(node_name(stone_type .. "_bricks"), {
-- 			description = description .. " Bricks",
-- 			tiles = {
-- 				texture(stone_type .. "_bricks")
-- 			},
-- 		})
-- 		minetest.register_node(node_name(stone_type .. "_cobble"), {
-- 			description = description .. " Cobble",
-- 			tiles = {
-- 				texture(stone_type .. "_cobble")
-- 			},
-- 		})
-- 		if shape_nodes then
-- 			shapes.register.quaters(node_name(stone_type), {
-- 				description = description,
-- 				tiles = {
-- 					world_tile(stone_type)
-- 				},
-- 			})
-- 			shapes.register.quaters(node_name(stone_type .. "_block"), {
-- 				description = description .. " Block",
-- 				tiles = {
-- 					world_tile(stone_type .. "_block")
-- 				},
-- 			})
-- 			-- shapes.register.quaters(node_name(stone_type), {
-- 			-- 	description = description,
-- 			-- 	tiles = {
-- 			-- 		world_tile(stone_type)
-- 			-- 	},
-- 			-- })
-- 		end
-- 	end
-- end
-- register_stones()
