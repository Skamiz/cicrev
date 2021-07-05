--[[

TODO: make it so that when a splitting log is dug it destroys any partialy split logs on top of it
Goals:
	Take a log and place it down. Now mine it with the splitting axe. A part of
	 the log is taken off and the resulting item is dispensed with slight
	 acceleration towards the direction from which the slice was taken.
	 Repeat n times to get n items from one log.
	 Repeat 8 times to get 8 planks, which can be crafted into 2 plank blocks.
	 OR
	 Dig one time with a saw to get 8 planks at once.

	 conditions
	 - if rotatable param2 must equal 0
	 - the node above must be air|not walkable (not covered)

	 Variation
	 - maybe also use to get slate/stone discs if there is a use for that.

splitting.register_recipe({
	input = "cicrev:log_dark",
	output = "cicrev:plank_dark",
	amount = 8,
	-- handle this with groups instead, splitting = 1|2
	tool = "cicrev:splitting_axe",
	advanced_tool = "cicrev:saw",

	-- optional
	innner_texture = "cicrev_log_dark_inside.png"
})



	202105025

	A chopping block
		place log on block
		each dig with a saw creates one plank

--]]
local mod_name = minetest.get_current_modname()
splitting = {}
splitting.recipes = {}

-- local function split_dig(pos, node, digger)
-- 	local wielded = digger:get_wielded_item()
-- 	local tool_def = minetest.registered_items[wielded:get_name()]
-- 	if tool_def.groups.splitt then
-- 		local recipe = splitting.recipes[node.name]
-- 	else
-- 		minetest.node_dig(pos, node, digger)
-- 	end
-- end

function splitting.register_recipe(recipe)
	splitting.recipes[recipe.input] = recipe


	local def = minetest.registered_nodes[recipe.input]
	local node_name = def.name:match(":.+")

	recipe.full_node_name = "splitting" .. node_name .. "_" .. recipe.amount

	minetest.register_alias("splitting" .. node_name .. "_0", "air")

	for i = 1, recipe.amount do
		local tiles = table.copy(def.tiles)
		for j = 2, 6 do if not tiles[j] then tiles[j] = tiles[j-1] end end
		if i ~= recipe.amount and recipe.innner_texture then
			tiles[3] = recipe.innner_texture
		end

		minetest.register_node(":splitting" .. node_name .. "_" .. i, {
			description = def.description .. " " .. i .. "/" .. recipe.amount,
			drawtype = "nodebox",
			tiles = tiles,
			node_box = {
				type = "fixed",
				fixed = {-0.5, -1, -0.5, (i / recipe.amount) - 0.5, 0, 0.5},
			},
			groups = {choppy = 1, not_in_creative_inventory = 1},
			drop = "",
			after_dig_node = function(pos, oldnode, oldmetadata, digger)
				minetest.set_node(pos, {name = "splitting" .. node_name .. "_" .. i-1})
				local output = ItemStack(recipe.output)
				pos.y = pos.y - 0.5
				pos.x = pos.x + ((i / recipe.amount) - 0.5)
				local item = minetest.add_item(pos, output)
				item:set_velocity({x = math.random()*2 + 2, y = math.random()*2, z = (math.random() - 0.5*2)})
			end,
		})
	end
end


minetest.register_node("splitting:chopping_block", {
	description = "Chopping Block",
	drawtype = "nodebox",
	-- TODO: chopping block needs it's own textures, also a recipe
	tiles = {"splittiong_chopping_block_top.png", "splittiong_chopping_block_top.png", "splittiong_chopping_block.png"},
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5 * (16/20), -0.5, 0.5, 0, 0.5},
	},
	visual_scale = 20/16,
	selection_box = {
		type = "fixed",
		fixed = {-10/16, -0.5, -10/16, 10/16, 0, 10/16},
	},
	collision_box = {
		type = "fixed",
		fixed = {-10/16, -0.5, -10/16, 10/16, 0, 10/16},
	},
	groups = {choppy = 1, wood = 1},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if pointed_thing.above.y > pointed_thing.under.y and
				splitting.recipes[itemstack:get_name()] then
			minetest.set_node(pointed_thing.above, {name = splitting.recipes[itemstack:get_name()].full_node_name})
			if not minetest.is_creative_enabled(clicker:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		else
			return minetest.item_place_node(itemstack, clicker, pointed_thing, param2, prevent_after_place)
		end
	end,
})

minetest.register_craft({
    output = "splitting:chopping_block",
    recipe = {
        {'group:log'},
    },
})
