-- ======
-- PLANTS
-- ======

minetest.register_node("cicrev:tall_grass_1", {
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	description = "Grass",
	tiles = {"cicrev_tall_grass.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	paramtype2 = "degrotate",
	walkable = false,
	buildable_to = true,
	drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})
minetest.register_node("cicrev:tall_grass_2", {
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	description = "Grass",
	tiles = {"cicrev_tall_grass_2.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	paramtype2 = "degrotate",
	walkable = false,
	buildable_to = true,
	drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})
minetest.register_node("cicrev:tall_grass_3", {
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	description = "Grass",
	tiles = {"cicrev_tall_grass_3.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	paramtype2 = "degrotate",
	walkable = false,
	buildable_to = true,
	drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})

minetest.register_node("cicrev:sawgrass", {
	drawtype = "plantlike",
	visual_scale = 2.0,
	description = "Sawgrass",
	tiles = {"cicrev_sawgrass.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	paramtype2 = "meshoptions",
	walkable = false,
	buildable_to = true,
	-- drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})
minetest.register_node("cicrev:sedge", {
	drawtype = "plantlike",
	-- visual_scale = 1.0,
	description = "Sedge",
	tiles = {"cicrev_sedge.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	paramtype2 = "meshoptions",
	walkable = false,
	buildable_to = true,
	-- drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})

-- =====
-- TREES
-- =====

-- tree
minetest.register_node("cicrev:sapling", {
	description = "Sapling",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"cicrev_sapling.png"},
	groups = {hand = 1},
	walkable = false,
	drop = "",
	selection_box = {
            type = "fixed",
            fixed = {
                {-4 / 16, -0.5, -4 / 16, 4 / 16, 6 / 16, 4 / 16},
            },
        },
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local t = minetest.get_node_timer(pos)
		t:start(math.random(60 * 20, 60 * 60))
	end,
	on_timer = function(pos, elapsed) -- TODO: replace with a 'grow_tree' function
		minetest.place_schematic(vector.add(pos, {x = -2, z = -2, y = 0}), minetest.get_modpath("cicrev").."/schematics/tree.mts", "random", nil, false)
	end,
})

minetest.register_node("cicrev:log", {
	description = "Log",
	tiles = {"cicrev_log_top.png", "cicrev_log_top.png", "cicrev_log.png"},
	paramtype2 = "facedir",
	groups = {choppy = 1, log = 1, wood = 1},
	on_place = place_pillar,
	node_placement_prediction = "",
	after_destruct = function(pos, oldnode)
		cicrev.update_touching_nodes(pos)
	end,
})

minetest.register_node("cicrev:leaves", {
	description = "Leaves",
	drawtype = "allfaces",
	paramtype = "light",
	tiles = {"cicrev_leaves.png"},
	groups = {hand = 1},
	walkable = false,
	drop = {
		max_items = 1,
		items = {
			{
				rarity = 50,
				items = {"cicrev:sapling"}
			},
			{
				rarity = 2,
				items = {"cicrev:stick"},
			},
		}
	},
	after_destruct = function(pos, oldnode)
		cicrev.update_touching_nodes(pos)
	end,
	_leaves = {
		grows_on = "cicrev:log",
		grow_distance = 3,
	},
	_on_update = cicrev.leaf_decay
})

-- dark tree
minetest.register_node("cicrev:sapling_dark", {
	description = "Dark Sapling",
	drawtype = "plantlike",
	paramtype = "light",
	tiles = {"cicrev_sapling_dark.png"},
	groups = {hand = 1},
	walkable = false,
	drop = "",
	selection_box = {
            type = "fixed",
            fixed = {
                {-4 / 16, -0.5, -4 / 16, 4 / 16, 6 / 16, 4 / 16},
            },
        },
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local t = minetest.get_node_timer(pos)
		t:start(math.random(60 * 20, 60 * 60))
	end,
	on_timer = function(pos, elapsed) -- TODO: replace with a 'grow_tree' function
		minetest.place_schematic(vector.add(pos, {x = -3, z = -3, y = 0}), minetest.get_modpath("cicrev").."/schematics/tree_dark.mts", "random", nil, false)
	end,
})

minetest.register_node("cicrev:log_dark", {
	description = "Dark Log",
	tiles = {"cicrev_log_top_dark.png", "cicrev_log_top_dark.png", "cicrev_log_dark.png"},
	paramtype2 = "facedir",
	groups = {choppy = 1, log = 1, wood = 1},
	on_place = place_pillar,
	node_placement_prediction = "",
	after_destruct = function(pos, oldnode)
		cicrev.update_touching_nodes(pos)
	end,
})

minetest.register_node("cicrev:leaves_dark", {
	description = "Dark Leaves",
	drawtype = "allfaces",
	paramtype = "light",
	tiles = {{name = "cicrev_leaves_dark.png"}},
	groups = {hand = 1},
	walkable = false,
	drop = {
		max_items = 1,
		items = {
			{
				rarity = 50,
				items = {"cicrev:sapling_dark"}
			},
			{
				rarity = 2,
				items = {"cicrev:stick"},
			},
		}
	},
	after_destruct = function(pos, oldnode)
		cicrev.update_touching_nodes(pos)
	end,
	_leaves = {
		grows_on = "cicrev:log_dark",
		grow_distance = 4,
	},
	_on_update = cicrev.leaf_decay
})

-- ====
-- WOOD
-- ====


minetest.register_node("cicrev:log_stripped", {
	description = "Log",
	tiles = {"cicrev_log_top.png", "cicrev_log_top.png", "cicrev_log_stripped.png"},
	paramtype2 = "facedir",
	groups = {choppy = 1, log = 1, wood = 1},
	on_place = place_pillar,
	node_placement_prediction = "",
})
minetest.register_node("cicrev:planks", {
	description = "Planks",
	tiles = {{name = "cicrev_planks.png", align_style = "world"}},
	groups = {choppy = 1, planks = 1, wood = 1},
})



minetest.register_node("cicrev:log_stripped_dark", {
	description = "Stripped Dark Log",
	tiles = {"cicrev_log_top_stripped_dark.png", "cicrev_log_top_stripped_dark.png", "cicrev_log_stripped_dark.png"},
	paramtype2 = "facedir",
	groups = {choppy = 1, log = 1, wood = 1},
	on_place = place_pillar,
	node_placement_prediction = "",
})
minetest.register_node("cicrev:planks_dark", {
	description = "Dark Planks",
	tiles = {"cicrev_planks_dark.png"},
	groups = {choppy = 1, planks = 1, wood = 1},
})
cicrev.regster_fence("cicrev:fence_dark", {
	description = "Dark Fence",
	tiles = {"cicrev_fence_dark_top.png", "cicrev_fence_dark_top.png", "cicrev_fence_dark_side.png"},
	groups = {choppy = 1, wood = 1},
})

-- =====
-- SOILS
-- =====

minetest.register_node("cicrev:dirt_with_grass", {
	description = "Grass",
	tiles = {"cicrev_grass_top.png", "cicrev_dirt.png", "cicrev_dirt.png^cicrev_grass_side.png"},
	groups = {hand = 1},
})

minetest.register_node("cicrev:dirt", {
	description = "Dirt",
	tiles = {"cicrev_dirt.png"},
	groups = {hand = 2},
})

minetest.register_node("cicrev:peat_with_moss", {
	description = "Moss",
	tiles = {"cicrev_peat_with_moss_top.png", "cicrev_peat.png"},
	groups = {hand = 1},
})


minetest.register_node("cicrev:peat", {
	description = "Peat",
	tiles = {"cicrev_peat.png"},
	groups = {hand = 2},
})

minetest.register_node("cicrev:sand", {
	description = "Sand",
	tiles = {"cicrev_sand.png"},
	groups = {hand = 2, falling_node = 1},
})

minetest.register_node("cicrev:gravel", {
	description = "Gravel",
	tiles = {"cicrev_gravel.png"},
	groups = {hand = 2, falling_node = 1},
})

-- ====
-- ORES
-- ====

minetest.register_node("cicrev:tetrahedrite", {
	description = "Tetrahedrite",
	tiles = {"cicrev_tetrahedrite.png"},
	groups = {hand = 2},
})
minetest.register_node("cicrev:bituminous_coal", {
	description = "Bituminous coal",
	tiles = {"cicrev_bituminous_coal.png"},
	groups = {hand = 2},
	drop = "cicrev:coal 3",
})

-- =======
-- LIQUIDS
-- =======

minetest.register_node("cicrev:water_source", {
	drawtype = "liquid",
	description = "Water",
	tiles = {{
		name = "cicrev_water_still.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
        	aspect_h = 16,
        	length = 3,
		}
	}},
	groups = {water = 1},
	paramtype = "light",
	pointable = false,
	buildable_to = true,
	walkable = false,
	liquidtype = "source",
	liquid_alternative_flowing = "cicrev:water_flowing",
	liquid_viscosity = 0,
	alpha = 200, --undocumented feature
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	-- liquid_renewable = true,
	-- liquid_range = 3,
})
minetest.register_node("cicrev:water_flowing", {
	drawtype = "flowingliquid",
	description = "Flowing water",
	tiles = {"cicrev_water.png"},
	-- special_tiles = {"cicrev_water.png", "cicrev_water.png"},
	special_tiles = {{
		name = "cicrev_water_flowing.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
        	aspect_h = 16,
        	length = 1,
		}
	},
	{
		name = "cicrev_water_flowing.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
        	aspect_h = 16,
        	length = 1,
		}
	}},
	groups = {water = 1},
	paramtype = "light",
	pointable = false,
	buildable_to = true,
	walkable = false,
	liquidtype = "flowing",
	liquid_alternative_source = "cicrev:water_source", -- this can be used to choose what is created on the creation of a new source
	liquid_alternative_flowing = "cicrev:water_flowing",
	liquid_viscosity = 0,
	liquid_renewable = true,
	liquid_range = 3,
	alpha = 200, --undocumented feature
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
})

-- ====
-- MISC
-- ====

minetest.register_node("cicrev:coal_arrow", {
	description = "_coal_arrow",
	drawtype = "nodebox",
	tiles = {"cicrev_arrow.png"},
	groups = {hand = 1},
	walkable = false,
	buildable_to = true,
	drop = "",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {type = "fixed",
		fixed = {-6/16,- 0.49, -7/16, 6/16, -0.49, 7/16}},
})

minetest.register_node("cicrev:crate", {
	description = "Crate",
	tiles = {"cicrev_crate.png"},
	groups = {hand = 2},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
    	inv:set_size("main", 8*4)
		meta:set_string("formspec",
            "size[8,9]"..
            "list[context;main;2,0;4,4;]"..
            "list[current_player;main;0,5;8,4;]"..
			"listring[]")
	end
})

minetest.register_node("cicrev:ladder", {
	description = "Ladder",
	drawtype = "signlike",
	tiles = {"cicrev_ladder.png"},
	inventory_image = "cicrev_ladder.png",
	wield_image = "cicrev_ladder.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	walkable = false,
	climbable = true,
	selection_box = {
		type = "wallmounted",
		--wall_top = = <default>
		--wall_bottom = = <default>
		--wall_side = = <default>
	},
	groups = {hand = 1, attached_node = 1},
})

minetest.register_node("cicrev:torch", {
	description = "torch",
	drawtype = "nodebox",
	tiles = {"cicrev_torch.png"},
	groups = {hand = 1, attached_node = 1},
	node_box = {type = "fixed", fixed = {-1/16, -8/16, -1/16, 1/16, 2/16, 1/16}},
	walkable = false,
	paramtype = "light",
	light_source = 8,
	on_construct = function(pos)
		get_and_set_timer(pos, 480) -- 8 minutes
	end,
	on_timer = function(pos, elapsed)
		minetest.remove_node(pos)
	end,
})

make_chiseable("cicrev:planks")
make_chiseable("cicrev:planks_dark")

local stones = {"andesite", "basalt", "chalk", "chert", "claystone",
    "conglomerate", "dacite", "diorite", "dolomite", "gabbro", "gneiss", "granite", "limestone",
    "marble", "mudstone", "obsidian", "phyllite", "quartzite", "rhyolite",
    "rocksalt", "sandstone", "schist", "shale", "siltstone", "slate"}
for _, v in pairs(stones) do
	make_chiseable("df_stones:" .. v)
end
