local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

--[[
cicrev:tall_grass_1
cicrev:tall_grass_2
cicrev:tall_grass_3
cicrev:sawgrass
cicrev:sedge
cicrev:moss


cicrev:fence_oak
cicrev:fence_chestnut
cicrev:fence_chaktekok
cicrev:fence_dark
cicrev:wall_dark

cicrev:soil
cicrev:peat
cicrev:loam
cicrev:clay
cicrev:silt
cicrev:sand
cicrev:gravel
cicrev:dirt_with_grass
cicrev:peat_with_moss

cicrev:path
cicrev:shingles

cicrev:tetrahedrite
cicrev:bituminous_coal

cicrev:water_source
cicrev:water_flowing

cicrev:coal_arrow
cicrev:crate
cicrev:glass
cicrev:ladder
cicrev:torch
cicrev:lantern
cicrev:fabric
cicrev:bricks
--]]

-- ======
-- PLANTS
-- ======

minetest.register_node("cicrev:tall_grass_1", {
	description = "Grass",
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	tiles = {"cicrev_tall_grass_1.png"},
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

minetest.register_node("cicrev:moss", {
	description = "Moss",
	drawtype = "nodebox",
	paramtype = "light",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	tiles = {"cicrev_moss.png"},
	groups = {hand = 1},
	walkable = false,
	buildable_to = true,
	connects_to = {"group:solid_node"},
	node_box = {
		type = "connected",
		connect_top = {-0.5, 6/16, -0.5, 0.5, 0.5, 0.5},
        connect_bottom = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5},
        connect_front = {-0.5, -0.5, -0.5, 0.5, 0.5, -6/16},
		connect_back = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5},
        connect_left = {-0.5, -0.5, -0.5, -6/16, 0.5, 0.5},
        connect_right = {6/16, -0.5, -0.5, 0.5, 0.5, 0.5},
		disconnected = {-6/16, -6/16, -6/16, 6/16, 6/16, 6/16},
	},
})


minetest.register_node("cicrev:tall_grass_dry_1", {
	description = "Grass",
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	tiles = {"cicrev_tall_grass_dry_1.png"},
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
minetest.register_node("cicrev:tall_grass_dry_2", {
	description = "Grass",
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	tiles = {"cicrev_tall_grass_dry_2.png"},
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
minetest.register_node("cicrev:tall_grass_dry_3", {
	description = "Grass",
	drawtype = "plantlike",
	-- visual_scale = 4.0,
	tiles = {"cicrev_tall_grass_dry_3.png"},
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

minetest.register_node("cicrev:sawgrass_dry", {
	description = "Sawgrass",
	drawtype = "plantlike",
	visual_scale = 2.0,
	tiles = {"cicrev_sawgrass_dry.png"},
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

cicrev.register_fence("cicrev:fence_oak", {
	description = "Oak Fence",
	tiles = {"cicrev_fence_oak_top.png", "cicrev_fence_oak_top.png", "cicrev_fence_oak_side.png"},
	groups = {choppy = 1, wood = 1},
	use_texture_alpha = "opaque",
})

cicrev.register_fence("cicrev:fence_chestnut", {
	description = "Chestnut Fence",
	tiles = {"cicrev_fence_chestnut_top.png", "cicrev_fence_chestnut_top.png", "cicrev_fence_chestnut_side.png"},
	groups = {choppy = 1, wood = 1},
	use_texture_alpha = "opaque",
})

cicrev.register_fence("cicrev:fence_chaktekok", {
	description = "Chakte Kok Fence",
	tiles = {"cicrev_fence_chaktekok_top.png", "cicrev_fence_chaktekok_top.png", "cicrev_fence_chaktekok_side.png"},
	groups = {choppy = 1, wood = 1},
	use_texture_alpha = "opaque",
})

cicrev.register_fence("cicrev:fence_dark", {
	description = "Dark Fence",
	tiles = {"cicrev_fence_dark_top.png", "cicrev_fence_dark_top.png", "cicrev_fence_dark_side.png"},
	groups = {choppy = 1, wood = 1},
	use_texture_alpha = "opaque",
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

minetest.register_node("cicrev:soil", {
	description = "Soil",
	tiles = {"cicrev_soil.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
})

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
	groups = {crumbly = 1, hand = 2, falling_node = 1, walkover_speed = 90},
})

minetest.register_node("cicrev:gravel", {
	description = "Gravel",
	tiles = {"cicrev_gravel.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
})

minetest.register_alias("cicrev:dirt_with_grass", "cicrev:soil_with_grass")
minetest.register_node("cicrev:soil_with_grass", {
	description = "Grass",
	tiles = {{name = "cicrev_grass_top_4x4.png", align_style = "world", scale = 4},
			"cicrev_soil.png", "cicrev_soil.png^cicrev_grass_side.png"},
	groups = {crumbly = 1, hand = 3},
	drop = "cicrev:soil",
})

minetest.register_node("cicrev:peat_with_moss", {
	description = "Grass",
	tiles = {"cicrev_peat_with_moss_top.png", "cicrev_peat.png"},
	groups = {hand = 1},
})

minetest.register_node("cicrev:loam_with_grass", {
	description = "Loam with Grass",
	tiles = {"cicrev_grass_top.png", "cicrev_loam.png", "cicrev_loam.png^cicrev_grass_side.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
	drop = "cicrev:loam",
})

minetest.register_node("cicrev:clay_with_grass", {
	description = "Clay with Grass",
	tiles = {"cicrev_grass_top.png", "cicrev_clay.png", "cicrev_clay.png^cicrev_grass_side.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
	drop = "cicrev:clay",
})

minetest.register_node("cicrev:silt_with_grass", {
	description = "Silt with Grass",
	tiles = {"cicrev_grass_top.png", "cicrev_silt.png", "cicrev_silt.png^cicrev_grass_side.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
	drop = "cicrev:silt",
})

minetest.register_node("cicrev:sand_with_grass", {
	description = "Sand with Grass",
	tiles = {"cicrev_grass_sand_top.png", "cicrev_sand.png", "cicrev_sand.png^cicrev_grass_sand_side.png"},
	groups = {crumbly = 1, hand = 2, falling_node = 1, walkover_speed = 90},
	drop = "cicrev:sand",
})

minetest.register_node("cicrev:gravel_with_grass", {
	description = "Gravel with Grass",
	tiles = {"cicrev_grass_top.png", "cicrev_gravel.png", "cicrev_gravel.png^cicrev_grass_side.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
	drop = "cicrev:gravel",
})

minetest.register_node("cicrev:silt_with_fungus", {
	description = "Silt with Grass",
	tiles = {"cicrev_fungus_top.png", "cicrev_silt.png", "cicrev_silt.png^cicrev_fungus_side.png"},
	groups = {crumbly = 1, hand = 3, falling_node = 1},
	drop = "cicrev:silt",
})

-- ===
-- SOMETHING
-- ===

minetest.register_node("cicrev:path", {
	description = "Path",
	tiles = {"cicrev_path.png"},
	groups = {cracky = 1, hand = 2, walkover_speed = 125},
})
minetest.register_node("cicrev:shingles", {
	description = "Shingles",
	tiles = {"cicrev_shingles.png"},
	groups = {cracky = 1, hand = 2},
})
make_chiseable("cicrev:shingles")

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
	use_texture_alpha = "clip",
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
            "formspec_version[4]"..
            "size[10.25,10.5]"..
            "container[0.25,0.25]" ..
            "list[context;main;2.5,0;4,4;]"..
            "list[current_player;main;0,5.25;8,4;]"..
            "container_end[]"..
			"listring[]")
	end
})

minetest.register_node("cicrev:glass", {
	description = "Glass",
	drawtype = "glasslike",
	tiles = {"cicrev_glass.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	sunlight_propagates = true,
	groups = {hand = 2},
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
	tiles = {"cicrev_torch_top.png", "cicrev_torch.png"},
	use_texture_alpha = "opaque",
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
minetest.register_node("cicrev:lantern", {
	description = "Lantern",
	drawtype = "nodebox",
	tiles = {"cicrev_lantern_top.png", "cicrev_lantern_top.png", "cicrev_lantern.png"},
	use_texture_alpha = "opaque",
	groups = {hand = 1},
	node_box = {
		type = "connected",
		fixed = {
			{-4/16, 3/16, -4/16, 4/16, 4/16, 4/16},
			{-3/16, -5/16, -3/16, 3/16, 5/16, 3/16},
		},
		connect_top = {-2/16, 5/16, -2/16, 2/16, 8/16, 2/16},
		connect_bottom = {-2/16, -8/16, -2/16, 2/16, -5/16, 2/16},
	},
	-- TODO: for whatever godforsaken reason, the connection doesn't work when the to be connected node is also a connected node
	connects_to = {"group:fence", "group:wall", "group:solid_node", "cicrev:lantern"},
	walkable = true,
	paramtype = "light",
	light_source = minetest.LIGHT_MAX,
	on_construct = function(pos)
		-- get_and_set_timer(pos, 480) -- 8 minutes
	end,
	on_timer = function(pos, elapsed)
		-- minetest.remove_node(pos)
	end,
})

minetest.register_node("cicrev:fabric", {
	description = "Fabric",
	tiles = {{name = "cicrev_fabric_4x4.png", align_style = "world", scale = 4}},
	-- tiles = {"cicrev_fabric.png"},
	groups = {hand = 1},
	paramtype2 = "color",
	-- palette = "cicrev_bears.png",
	-- palette = "cicrev_fabric.png^[brighten",
	palette = "cicrev_fabric_pallete.png",
	drop = "cicrev:fabric",
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		-- local pos = pointed_thing.above
		-- local param2 = pos.x%16 + (pos.z%16 * 16)
		-- minetest.item_place(itemstack, placer, pointed_thing, param2)
		minetest.item_place(itemstack, placer, pointed_thing, math.random(0,15))
	end,
	color = {r = 214, g = 200, b = 177, a = 255}
})

minetest.register_node("cicrev:bricks", {
	-- TODO:needs inventory_image
	description = "Bricks",
	inventory_image = minetest.inventorycube("cicrev_bricks_inventory.png", nil, nil),
	tiles = {{name = "cicrev_bricks_4x4.png", align_style = "world", scale = 4}},
	overlay_tiles = {{name = "cicrev_bricks_overlay_4x4.png", align_style = "world", scale = 4, color = "#ffffff"}},
	groups = {hand = 1},
	paramtype2 = "color",
	palette = "cicrev_bricks_pallete.png",
	drop = "cicrev:fabric",
	node_placement_prediction = "",
	on_place = function(itemstack, placer, pointed_thing)
		minetest.item_place(itemstack, placer, pointed_thing, math.random(0,255))
	end,
})
make_chiseable("cicrev:bricks")




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
