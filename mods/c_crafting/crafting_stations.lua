
-- c_crafting.regsiter_station("c_crafting:workbench", {
-- get full recipe list for this station

-- })
--[[
_crafting_station_def = {
	get_recipes = function(crafter, crafting_station) return recipes end,
	get_input_list = function(crafter, crafting_station) return inputs end,
	get_craft_count = function(recipe, inputs) return count, partial end,

	get_craft_result = function(recipe, count) return consumed, created end,
	apply_craft_result = function(crafter, crafting_station, consumed, created) end,
}

on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
	start_crafting(clicker, node, pos)
end,

core.register_on_player_receive_fields(function(player, formname, fields)
if form name
_crafting_station data
selected recipe
end)
crafting_station = {
	nodname/"player",
	pos,
}
]]


core.register_node("c_crafting:workbench", {
	description = "Workbench",
	tiles = {"cicrev_planks_oak.png"},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16,  0/16, -8/16,  8/16,  4/16,  8/16},
			{-8/16, -8/16, -8/16, -4/16,  0/16, -4/16},
			{ 4/16, -8/16,  4/16,  8/16,  0/16,  8/16},
			{-8/16, -8/16,  4/16, -4/16,  0/16,  8/16},
			{ 4/16, -8/16, -8/16,  8/16,  0/16, -4/16},
		},
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local crafting_station = {
			name = node.name,
			pos = pos,
			crafting_def = core.registered_nodes[node.name]._crafting_station_def
		}
		c_crafting.initiate_crafting(clicker, crafting_station)
	end,
	after_destruct = c_crafting.after_crafting_station_destruct,
	_crafting_station_def = {
		get_recipes = function(crafter, crafting_station)
			return c_recipes.recipes_by_group["crafting_workbench"]
		end,
		get_input_list = c_crafting.get_player_inventory,
		get_craft_count = c_crafting.get_craft_count,

		get_craft_result = c_crafting.get_craft_result,
		apply_craft_result = c_crafting.apply_craft_result,
	},
	groups = {crafting_station = 1,},
})

core.register_node("c_crafting:kiln", {
	description = "Brick Kiln",
	tiles = {"cicrev_kiln_top.png", "cicrev_kiln_bottom.png", "cicrev_kiln_side.png", "cicrev_kiln_side.png", "cicrev_kiln_front.png"},
	paramtype2 = "facedir",
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local crafting_station = {
			name = node.name,
			pos = pos,
			crafting_def = core.registered_nodes[node.name]._crafting_station_def
		}
		c_crafting.initiate_crafting(clicker, crafting_station)
	end,
	after_destruct = c_crafting.after_crafting_station_destruct,
	_crafting_station_def = {
		get_recipes = function(crafter, crafting_station)
			return c_recipes.recipes_by_group["crafting_smelt"]
		end,
		get_input_list = c_crafting.get_player_inventory,
		get_craft_count = c_crafting.get_craft_count,

		get_craft_result = c_crafting.get_craft_result,
		apply_craft_result = c_crafting.apply_craft_result,
	},
	groups = {crafting_station = 1, cracky = 1},
})
