--[[
TODO:
besides all the other things it might be nice to have a more styllisied rock texture

]]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local stones = {"Andesite", "Basalt", "Chalk", "Chert", "Claystone",
    "Conglomerate", "Dacite", "Diorite", "Dolomite", "Gabbro", "Gneiss", "Granite", "Limestone",
    "Marble", "Mudstone", "Obsidian", "Phyllite", "Quartzite", "Rhyolite",
    "Rocksalt", "Sandstone", "Schist", "Shale", "Siltstone", "Slate"}

sedimentary = {"chalk", "chert", "claystone", "conglomerate", "dolomite",
    "limestone", "mudstone", "rocksalt", "sandstone", "shale", "siltstone"}

i_extrusive = {"andesite", "basalt", "dacite", "obsidian", "rhyolite"}

metamorphic = {"gneiss", "marble", "phyllite", "quartzite", "schist", "slate"}

i_intrusive = {"diorite", "gabbro", "granite"}

local texture_path = modpath .. "/textures"
local texture_list = minetest.get_dir_list(texture_path, false)
local mod_textures ={}
for k ,file in pairs(texture_list) do
	mod_textures[file] = true
end
texture_list = nil

for _, v in pairs(stones) do
    local lower = string.lower(v)
	local name = modname .. ":" .. lower
	local cobble_name = name .. "_cobblestone"
	local brick_name = name .. "_bricks"
	local block_name = name .. "_block"
	local rock_name = name .. "_rock"

	local texture_name = modname .. "_" .. lower

    minetest.register_node(name, {
        description = v,
        tiles = {texture_name .. ".png"},
        groups = {cracky = 1, natural_stone = 1},
		drop = rock_name .. " 2",
    })

	local cobble_texture = texture_name .. "_cobble.png"
    minetest.register_node(cobble_name, {
        description = v .. " Cobblestone",
        tiles = {mod_textures[cobble_texture] and cobble_texture or texture_name .. ".png^df_stones_cobble.png"},
        groups = {cracky = 1},
    })

	local bricks_texture = texture_name .. "_bricks.png"
    minetest.register_node(brick_name, {
        description = v .. " Bricks",
        tiles = {mod_textures[bricks_texture] and bricks_texture or texture_name .. ".png^df_stones_brick.png"},
        groups = {cracky = 1},
    })
	local block_texture = texture_name .. "_block.png"
    minetest.register_node(block_name, {
        description = v .. " Block",
        tiles = {mod_textures[block_texture] and block_texture or texture_name .. ".png^df_stones_block.png"},
        groups = {cracky = 1},
    })

	minetest.register_node(rock_name, {
		description = v .. " Rock",
		drawtype = "nodebox",
		-- inventory_image = texture_name .. ".png^df_stones_rock.png^[makealpha:255,0,255",
		tiles = {texture_name .. ".png"},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
        stack_max = 16,
        groups = {cracky = 1, hand = 1, falling_node = 1},
		node_box = {type = "fixed", fixed = {-5/16, -0.5, -1/16, 1/16, -5/16, 4/16}},
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local node = minetest.get_node(pos)
			node.param2 = math.random(4) - 1
			minetest.swap_node(pos, node)
		end,
	})

	-- minetest.register_craftitem(rock_name, {
	-- 	description = v .. " Rock",
	-- 	inventory_image = texture_name .. ".png^df_stones_rock.png^[makealpha:255,0,255",
	-- 	stack_max = 64,
	-- })

	local recipes = minetest.get_modpath("fast_craft")
	local walls = minetest.get_modpath("shapes")

	if recipes then
		fast_craft.register_craft({
			output = {cobble_name},
			input = {
				[rock_name] = 4,
			},
		})
	end

	if walls then
		shapes.register.wall(modname .. ":wall_brick_" .. lower, {
			description = v .. " Brick Wall",
			tiles = {{name = mod_textures[bricks_texture] and bricks_texture or texture_name .. ".png^df_stones_brick.png"}},
		})

		if recipes then
			fast_craft.register_craft({
				output = {modname .. ":wall_brick_" .. lower},
				input = {
					[brick_name] = 1,
				},
			})
		end
	end
end
