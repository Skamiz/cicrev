local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

--[[
Pure recipe API

What is crafting???

example recipes:

craft wood and stone into a stone pickaxe
craft wood and iron into an iron pickaxe at an anvil
when crafting, consume staming/energy, whatever

recipe def:{
	name = "", -- unique string: "mod_name:recipe_name"
	mod_origin = minetest.get_current_modname(),
	image = "image.png", default to first output if not present
	description = "",
	inputs = {[itemname] = amount, ...},
	outputs = {},
	groups = {group_name = 4},
	on_craft = func(crafter),
	-- crafter may be player, or table with info about the machine that did it which should include a pos
	maybe return value changes craft result?
	_custom fields,
}


API
register recipe
unregister recipe
get recipes by inputs --get recipes with matching input list
get recipes by outputs -\\- output list
register on craft(recipe, crafter)
get filtered recipe list(filter func(recipe))


c_recipes = {
	registered_recipes = {},
	--these are generated once after mods loaded then
	--they need to be updated if recipes are added or removed during runtime
	recipes_by_input = {
		[itemname] = {[name] = def, ...}
		[itemname] = {}
	}
	recipes_by_output = {
		[itemname] = {}
		[itemname] = {}
	}
	recipes_by_group = {
		[groupname] = {}
		group:crafting_anvil, group:crafting_loom, ... group:personal_recipe
		group:personal_recipe, limited to that specific player, though this mod doesn't care about that, that falls to crafting mod
	}
}


at the end, a validation step, to check that used items exist

maybe! function to create a formspec that show a given recipe
]]

c_recipes = {}

dofile(modpath .. "/api.lua")
