local modname = minetest.get_current_modname()
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

	minetest.register_node("cicrev:sapling_" .. name, {
		description = description .. " Sapling",
		drawtype = "plantlike",
		paramtype = "light",
		tiles = {"cicrev_sapling_" .. name .. ".png"},
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
			-- t:start(math.random(60 * 20, 60 * 60))
			t:start(math.random(1, 5))
		end,
		on_timer = function(pos, elapsed)
			minetest.remove_node(pos)
			place_schematic(pos, modpath .. "/schematics/tree_" .. name .. ".mts", "random", nil, false, "place_center_x, place_center_z")
		end,
	})

	minetest.register_node("cicrev:leaves_" .. name, {
		description = description .. " Leaves",
		drawtype = "allfaces_optional",
		paramtype = "light",
		tiles = {"cicrev_leaves_" .. name .. ".png"},
		groups = {hand = 1, leaves = 1},
		walkable = false,
		drop = {
			max_items = 1,
			items = {
				{
					rarity = 50,
					items = {"cicrev:sapling_" .. name}
				},
				{
					rarity = 2,
					items = {"cicrev:stick"},
				},
			}
		},
		_leaves = {
			grows_on = {
				["cicrev:log_" .. name] = true,
				["cicrev:bark_" .. name] = true,
			},
			grow_distance = leaf_distance,
		},
		_on_update = cicrev.leaf_decay
	})

	minetest.register_node("cicrev:log_" .. name, {
		description = description .. " Log",
		tiles = {"cicrev_log_top_" .. name .. ".png", "cicrev_log_top_" .. name .. ".png", "cicrev_log_" .. name .. ".png"},
		paramtype2 = "facedir",
		groups = {choppy = 1, log = 1, wood = 1},
		on_place = place_pillar,
		node_placement_prediction = "",
	})

	minetest.register_node("cicrev:log_stripped_" .. name, {
		description = "Stripped " .. description .. " Log",
		tiles = {"cicrev_log_top_stripped_" .. name .. ".png", "cicrev_log_top_stripped_" .. name .. ".png", "cicrev_log_stripped_" .. name .. ".png"},
		paramtype2 = "facedir",
		groups = {choppy = 1, log = 1, wood = 1},
		on_place = place_pillar,
		node_placement_prediction = "",
	})

	minetest.register_node("cicrev:bark_" .. name, {
		description = description .. " Bark",
		tiles = {"cicrev_log_" .. name .. ".png"},
		paramtype2 = "facedir",
		groups = {choppy = 1, log = 1, wood = 1},
		on_place = place_pillar,
		node_placement_prediction = "",
	})

	minetest.register_node("cicrev:bark_stripped_" .. name, {
		description = "Stripped " .. description .. " Bark",
		tiles = {"cicrev_log_stripped_" .. name .. ".png"},
		paramtype2 = "facedir",
		groups = {choppy = 1, log = 1, wood = 1},
		on_place = place_pillar,
		node_placement_prediction = "",
	})

	minetest.register_node("cicrev:planks_" .. name, {
		description = description .. " Planks",
		tiles = {{name = "cicrev_planks_" .. name .. ".png", align_style = "world"}},
		groups = {choppy = 1, planks = 1, wood = 1},
	})
	make_chiseable("cicrev:planks_" .. name)

	minetest.register_craftitem("cicrev:plank_" .. name, {
		description = description .. "Plank",
		inventory_image = "cicrev_plank_" .. name .. ".png",
	})

	-- Recipes
	-- Bark
	minetest.register_craft({
	    output = "cicrev:bark_" .. name .. " 3",
	    recipe = {
	            {"cicrev:log_" .. name, "cicrev:log_" .. name},
	            {"cicrev:log_" .. name, "cicrev:log_" .. name},
	        },
	})
	-- Planks
	minetest.register_craft({
		output = "cicrev:planks_" .. name,
		recipe = {
				{"cicrev:plank_" .. name, "cicrev:plank_" .. name},
				{"cicrev:plank_" .. name, "cicrev:plank_" .. name},
			},
	})

	if minetest.get_modpath("splitting") then
		splitting.register_recipe({
			input = "cicrev:log_" .. name,
			output = "cicrev:plank_" .. name,
			amount = 8,
			innner_texture = "cicrev_log_inside_" .. name .. ".png"
		})
		splitting.register_recipe({
			input = "cicrev:log_stripped_" .. name,
			output = "cicrev:plank_" .. name,
			amount = 8,
			innner_texture = "cicrev_log_inside_stripped_" .. name .. ".png"
		})
		splitting.register_recipe({
			input = "cicrev:bark_" .. name,
			output = "cicrev:plank_" .. name,
			amount = 8,
			innner_texture = "cicrev_log_inside_" .. name .. ".png"
		})
		splitting.register_recipe({
			input = "cicrev:bark_stripped_" .. name,
			output = "cicrev:plank_" .. name,
			amount = 8,
			innner_texture = "cicrev_log_inside_stripped_" .. name .. ".png"
		})
	else
		minetest.register_craft({
		    output = "cicrev:plank_" .. name .. " 8",
		    recipe = {
		            {"cicrev:log_" .. name},
		        },
		})
		minetest.register_craft({
		    output = "cicrev:plank_" .. name .. " 8",
		    recipe = {
		            {"cicrev:log_stripped_" .. name},
		        },
		})
		minetest.register_craft({
		    output = "cicrev:plank_" .. name .. " 8",
		    recipe = {
		            {"cicrev:bark_" .. name},
		        },
		})
		minetest.register_craft({
		    output = "cicrev:plank_" .. name .. " 8",
		    recipe = {
		            {"cicrev:bark_stripped_" .. name},
		        },
		})
	end

	if minetest.get_modpath("falling_trees") then
		falling_trees.register_tree({
			logs = {"cicrev:log_" .. name, "cicrev:bark_" .. name},
			leaves = {"cicrev:leaves_" .. name}
		})
	end

end
