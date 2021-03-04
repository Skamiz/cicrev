local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

--[[
cicrev:tall_grass_1
cicrev:tall_grass_2
cicrev:tall_grass_3
cicrev:sawgrass
cicrev:sedge


cicrev:fence_dark
cicrev:wall_dark

cicrev:peat
cicrev:loam
cicrev:soil
cicrev:clay
cicrev:silt
cicrev:sand
cicrev:gravel
cicrev:dirt_with_grass
cicrev:peat_with_moss

cicrev:tetrahedrite
cicrev:bituminous_coal

cicrev:water_source
cicrev:water_flowing

cicrev:coal_arrow
cicrev:crate
cicrev:ladder
cicrev:torch
--]]

-- ======
-- PLANTS
-- ======

minetest.register_node("cicrev:tall_grass_1", {
	description = "Grass",
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	tiles = {"cicrev_tall_grass.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "degrotate",
	walkable = false,
	buildable_to = true,
	drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})
minetest.register_node("cicrev:tall_grass_2", {
	description = "Grass",
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	tiles = {"cicrev_tall_grass_2.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "degrotate",
	walkable = false,
	buildable_to = true,
	drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})
minetest.register_node("cicrev:tall_grass_3", {
	description = "Grass",
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	tiles = {"cicrev_tall_grass_3.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "degrotate",
	walkable = false,
	buildable_to = true,
	drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})

minetest.register_node("cicrev:sawgrass", {
	description = "Sawgrass",
	drawtype = "plantlike",
	visual_scale = 2.0,
	tiles = {"cicrev_sawgrass.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "meshoptions",
	walkable = false,
	buildable_to = true,
	-- drop = "cicrev:grass",
	selection_box = {type = "fixed",
		fixed = {-5/16, -0.5, -5/16, 5/16, -3/16, 5/16}},
})
minetest.register_node("cicrev:sedge", {
	description = "Sedge",
	drawtype = "plantlike",
	-- visual_scale = 1.0,
	tiles = {"cicrev_sedge.png"},
	groups = {hand = 1, attached_node = 1},
	paramtype = "light",
	sunlight_propagates = true,
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

cicrev.register_tree("oak", "Oak", 3)
cicrev.register_tree("dark", "Dark", 4)
cicrev.register_tree("chaktekok", "Chakte Kok", 4)
cicrev.register_tree("chestnut", "Chestnut", 4)


-- ====
-- WOOD
-- ====

cicrev.register_fence("cicrev:fence_dark", {
	description = "Dark Fence",
	tiles = {"cicrev_fence_dark_top.png", "cicrev_fence_dark_top.png", "cicrev_fence_dark_side.png"},
	groups = {choppy = 1, wood = 1},
})

cicrev.register_wall("cicrev:wall_dark", {
	description = "Dark Wall",
	tiles = {"cicrev_planks_dark.png"},
	groups = {choppy = 1, wood = 1},
})

-- =====
-- SOILS
-- =====

-- TODO: add loam, a source of clay(clay loam)
-- anorganic
-- sand + silt + clay = loam
-- mud + grass = adobe

-- organic
-- peat
-- soil?

minetest.register_node("cicrev:peat", {
	description = "Peat",
	tiles = {"cicrev_peat.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
})

minetest.register_node("cicrev:loam", {
	description = "Loam",
	tiles = {"cicrev_loam.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
})

minetest.register_node("cicrev:soil", {
	description = "Soil",
	tiles = {"cicrev_soil.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
})

minetest.register_node("cicrev:clay", {
	description = "Clay",
	tiles = {"cicrev_clay.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
})

minetest.register_node("cicrev:silt", {
	description = "Silt",
	tiles = {"cicrev_silt.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
})

minetest.register_node("cicrev:sand", {
	description = "Sand",
	tiles = {"cicrev_sand.png"},
	groups = {crumbly = 1, hand = 2, falling_node = 1},
})

minetest.register_node("cicrev:gravel", {
	description = "Gravel",
	tiles = {"cicrev_gravel.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
})

minetest.register_node("cicrev:dirt_with_grass", {
	description = "Grass",
	tiles = {"cicrev_grass_top.png", "cicrev_loam.png", "cicrev_soil.png^cicrev_grass_side.png"},
	groups = {crumbly = 1, hand = 3},
	drop = "cicrev:soil",
})

minetest.register_node("cicrev:peat_with_moss", {
	description = "Moss",
	tiles = {"cicrev_peat_with_moss_top.png", "cicrev_peat.png"},
	groups = {hand = 1},
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
	description = "Water",
	drawtype = "liquid",
	-- tiles = {"cicrev_water.png^[opacity:150"},
	tiles = {{
		name = "cicrev_water_still.png^[opacity:150",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3,
		}
	}},
	use_texture_alpha = "blend",
	groups = {water = 1},
	paramtype = "light",
	pointable = false,
	buildable_to = true,
	walkable = false,
	liquidtype = "source",
	liquid_alternative_flowing = "cicrev:water_flowing",
	liquid_viscosity = 0,
	post_effect_color = {a = 103, r = 30, g = 60, b = 90},
	-- liquid_renewable = true,
	-- liquid_range = 3,
})
minetest.register_node("cicrev:water_flowing", {
	description = "Flowing water",
	drawtype = "flowingliquid",
	-- tiles = {"cicrev_water.png^[opacity:150"},
	-- special_tiles = {"cicrev_water.png", "cicrev_water.png"},
	special_tiles = {{
		name = "cicrev_water_flowing.png^[opacity:150",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
        	aspect_h = 16,
        	length = 1,
		}
	},
	{
		name = "cicrev_water_flowing.png^[opacity:150",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
        	aspect_h = 16,
        	length = 1,
		}
	}},
	use_texture_alpha = "blend",
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
	description = "Torch",
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

local stones = {"andesite", "basalt", "chalk", "chert", "claystone",
    "conglomerate", "dacite", "diorite", "dolomite", "gabbro", "gneiss", "granite", "limestone",
    "marble", "mudstone", "obsidian", "phyllite", "quartzite", "rhyolite",
    "rocksalt", "sandstone", "schist", "shale", "siltstone", "slate"}
for _, v in pairs(stones) do
	local stone = "df_stones:" .. v
	make_chiseable(stone)
	minetest.override_item(stone, {
		_on_update = function(pos_center)
			for _, pos in pairs(cicrev.get_touching_nodes(pos_center)) do
				if minetest.registered_nodes[minetest.get_node(pos).name].walkable then return end
			end
			minetest.remove_node(pos_center)
			minetest.add_item(pos_center, stone)
		end
	})
end
