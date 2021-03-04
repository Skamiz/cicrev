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

	minetest.register_craftitem(rock_name, {
		description = v .. " Rock",
		inventory_image = texture_name .. ".png^df_stones_rock.png^[makealpha:255,0,255",
		stack_max = 64,
	})

	minetest.register_craft({
	    output = cobble_name,
	    recipe = {
	        {rock_name, rock_name},
	        {rock_name, rock_name},
	    },
	})



end
