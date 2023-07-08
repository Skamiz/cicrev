local modname = minetest.get_current_modname()
local modprefix = modname .. ":"
local modpath = minetest.get_modpath(modname)

--[[
registers:
	sapling
	leaves
	log
	stripped log
	planks
--]]

local place_schematic = schem.place_tree or minetest.place_schematic

function cicrev.register_tree(name, description, leaf_distance)
	assert(name and type(name) == "string", "A tree registration doesn't provide a valid name.")
	local description = description or "Unspecified"
	local leaf_distance = leaf_distance or 3

	-- I could save me some concatations by doing them once here, istead everytime I need them

	minetest.register_node(modprefix .. "sapling_" .. name, {
		description = description .. " Sapling",
		drawtype = "plantlike",
		paramtype = "light",
		tiles = {"cicrev_sapling_" .. name .. ".png"},
		inventory_image = "cicrev_sapling_" .. name .. ".png",
		groups = {hand = 1, sapling = 1},
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
			-- t:start(math.random(1, 5))
		end,
		on_timer = function(pos, elapsed)
			minetest.remove_node(pos)
			place_schematic(pos, modpath .. "/schematics/tree_" .. name .. ".mts", "random", nil, false, "place_center_x, place_center_z")
		end,
	})

	minetest.register_node(modprefix .. "leaves_" .. name, {
		description = description .. " Leaves",
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = {"cicrev_leaves_" .. name .. ".png"},
		-- tiles = {"cicrev_leaves_simple_" .. name .. ".png"},
		groups = {hand = 1, leaves = 1},
		walkable = false,
		move_resistance = 1,
		drop = {
			max_items = 1,
			items = {
				{
					rarity = 50,
					items = {modprefix .. "sapling_" .. name}
				},
				{
					rarity = 2,
					items = {modprefix .. "stick"},
				},
			}
		},
		_leaves = {
			grows_on = {
				[modprefix .. "log_" .. name] = true,
				[modprefix .. "bark_" .. name] = true,
				[modprefix .. "branch_" .. name] = true,
			},
			grow_distance = leaf_distance,
		},
		_on_update = cicrev.leaf_decay
	})

	minetest.register_node(modprefix .. "log_" .. name, {
		description = description .. " Log",
		tiles = {"cicrev_log_top_" .. name .. ".png", "cicrev_log_top_" .. name .. ".png", "cicrev_log_" .. name .. ".png"},
		paramtype2 = "facedir",
		groups = {choppy = 1, log = 1, wood = 1},
		on_place = place_pillar,
		node_placement_prediction = "",
	})

	minetest.register_node(modprefix .. "log_stripped_" .. name, {
		description = "Stripped " .. description .. " Log",
		tiles = {"cicrev_log_top_stripped_" .. name .. ".png", "cicrev_log_top_stripped_" .. name .. ".png", "cicrev_log_stripped_" .. name .. ".png"},
		paramtype2 = "facedir",
		groups = {choppy = 1, log = 1, wood = 1},
		on_place = place_pillar,
		node_placement_prediction = "",
	})

	minetest.register_node(modprefix .. "bark_" .. name, {
		description = description .. " Bark",
		tiles = {"cicrev_log_" .. name .. ".png"},
		paramtype2 = "facedir",
		groups = {choppy = 1, log = 1, wood = 1},
		on_place = place_pillar,
		node_placement_prediction = "",
	})

	minetest.register_node(modprefix .. "bark_stripped_" .. name, {
		description = "Stripped " .. description .. " Bark",
		tiles = {"cicrev_log_stripped_" .. name .. ".png"},
		paramtype2 = "facedir",
		groups = {choppy = 1, log = 1, wood = 1},
		on_place = place_pillar,
		node_placement_prediction = "",
	})

	minetest.register_node(modprefix .. "branch_" .. name, {
		description = description .. " Branch",
		tiles = {"cicrev_log_" .. name .. ".png"},
		groups = {choppy = 1, branch = 1},
		paramtype = "light",
		drawtype = "nodebox",
		node_box = {
			type = "connected",
			fixed          = {-0.25, -0.25, -0.25, 0.25,  0.25, 0.25},
			connect_top    = {-0.25, -0.25, -0.25, 0.25,  0.5,  0.25}, -- y+
			connect_bottom = {-0.25, -0.5,  -0.25, 0.25,  0.25, 0.25}, -- y-
			connect_front  = {-0.25, -0.25, -0.5,  0.25,  0.25, 0.25}, -- z-
			connect_back   = {-0.25, -0.25,  0.25, 0.25,  0.25, 0.5 }, -- z+
			connect_left   = {-0.5,  -0.25, -0.25, 0.25,  0.25, 0.25}, -- x-
			connect_right  = {-0.25, -0.25, -0.25, 0.5,   0.25, 0.25}, -- x+
		},
		connects_to = {"group:tree", "group:log", "group:leaves", "group:branch"},
	})

	minetest.register_node(modprefix .. "planks_" .. name, {
		description = description .. " Planks",
		tiles = {{name = "cicrev_planks_" .. name .. ".png", align_style = "world"}},
		groups = {choppy = 1, planks = 1, wood = 1},
	})
	make_chiseable(modprefix .. "planks_" .. name)

	minetest.register_node(modprefix .. "panel_" .. name, {
		description = description .. " Panel",
		tiles = {{name = "cicrev_planks_" .. name .. ".png", align_style = "world"}},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {choppy = 1, planks = 1, wood = 1},
		node_box = {
			type = "fixed",
			fixed = {-8/16, -8/16, -8/16, 8/16, -4/16, 8/16}
		},
		node_placement_prediction = "",
		on_place = minetest.rotate_node,
	})

	minetest.register_craftitem(modprefix .. "plank_" .. name, {
		description = description .. " Plank",
		inventory_image = "cicrev_plank_" .. name .. ".png",
		groups = {plank = 1},
	})

	-- Recipes
	-- Bark
	fast_craft.register_craft({
		output = {modprefix .. "bark_" .. name, 2},
		additional_output = {
			[modprefix .. "log_stripped_" .. name] = 1
		},
		input = {
			[modprefix .. "log_" .. name] = 3,
		},
	})
	-- Planks
	fast_craft.register_craft({
		output = {modprefix .. "planks_" .. name},
		input = {
			[modprefix .. "plank_" .. name] = 4,
		},
	})
	-- minetest.register_craft({
	-- 	output = modprefix .. "planks_" .. name,
	-- 	recipe = {
	-- 			{modprefix .. "plank_" .. name, modprefix .. "plank_" .. name},
	-- 			{modprefix .. "plank_" .. name, modprefix .. "plank_" .. name},
	-- 		},
	-- })

	if minetest.get_modpath("splitting") then
		splitting.register_recipe({
			input = modprefix .. "log_" .. name,
			output = modprefix .. "plank_" .. name,
			amount = 8,
			innner_texture = "cicrev_log_inside_" .. name .. ".png"
		})
		splitting.register_recipe({
			input = modprefix .. "log_stripped_" .. name,
			output = modprefix .. "plank_" .. name,
			amount = 8,
			innner_texture = "cicrev_log_inside_stripped_" .. name .. ".png"
		})
		splitting.register_recipe({
			input = modprefix .. "bark_" .. name,
			output = modprefix .. "plank_" .. name,
			amount = 8,
			innner_texture = "cicrev_log_inside_" .. name .. ".png"
		})
		splitting.register_recipe({
			input = modprefix .. "bark_stripped_" .. name,
			output = modprefix .. "plank_" .. name,
			amount = 8,
			innner_texture = "cicrev_log_inside_stripped_" .. name .. ".png"
		})
	else
		minetest.register_craft({
		    output = modprefix .. "plank_" .. name .. " 8",
		    recipe = {
		            {modprefix .. "log_" .. name},
		        },
		})
		minetest.register_craft({
		    output = modprefix .. "plank_" .. name .. " 8",
		    recipe = {
		            {modprefix .. "log_stripped_" .. name},
		        },
		})
		minetest.register_craft({
		    output = modprefix .. "plank_" .. name .. " 8",
		    recipe = {
		            {modprefix .. "bark_" .. name},
		        },
		})
		minetest.register_craft({
		    output = modprefix .. "plank_" .. name .. " 8",
		    recipe = {
		            {modprefix .. "bark_stripped_" .. name},
		        },
		})
	end

	if minetest.get_modpath("falling_trees") then
		falling_trees.register_tree({
			logs = {modprefix .. "log_" .. name, modprefix .. "bark_" .. name},
			leaves = {modprefix .. "leaves_" .. name, modprefix .. "branch_" .. name}
		})
	end

end
