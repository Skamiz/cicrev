local mod_name = minetest.get_current_modname()
local stones = {"Andesite", "Basalt", "Chalk", "Chert", "Claystone",
    "Conglomerate", "Dacite", "Diorite", "Dolomite", "Gabbro", "Gneiss", "Granite", "Limestone",
    "Marble", "Mudstone", "Obsidian", "Phyllite", "Quartzite", "Rhyolite",
    "Rocksalt", "Sandstone", "Schist", "Shale", "Siltstone", "Slate"}

sedimentary = {"chalk", "chert", "claystone", "conglomerate", "dolomite",
    "limestone", "mudstone", "rocksalt", "sandstone", "shale", "siltstone"}

i_extrusive = {"andesite", "basalt", "dacite", "obsidian", "rhyolite"}

metamorphic = {"gneiss", "marble", "phyllite", "quartzite", "schist", "slate"}

i_intrusive = {"diorite", "gabbro", "granite"}

for _, v in pairs(stones) do
    local lower = string.lower(v)
	local name = mod_name .. ":" .. lower
	local cobble_name = name .. "_cobblestone"
	local rock_name = name .. "_rock"

	local texture_name = mod_name .. "_" .. lower

    minetest.register_node(name, {
        description = v,
        tiles = {texture_name .. ".png"},
        groups = {cracky = 1},
		drop = rock_name,
    })


    minetest.register_node(cobble_name, {
        description = v .. " Cobblestone",
        tiles = {texture_name .. ".png^df_stones_cobble.png"},
        groups = {cracky = 1},
    })

	minetest.register_node(rock_name, {
		description = v .. " Rock",
		drawtype = "nodebox",
		inventory_image = texture_name .. ".png^df_stones_rock.png^[makealpha:255,0,255",
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

	minetest.register_craft({
	    output = cobble_name,
	    recipe = {
	        {rock_name, rock_name},
	        {rock_name, rock_name},
	    },
	})



end
