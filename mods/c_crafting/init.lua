local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
c_crafting = {}

dofile(modpath .. "/functions.lua")
dofile(modpath .. "/crafting_stations.lua")
dofile(modpath .. "/formspec.lua")

--[[
Does:
crafting stations
	anvil, workbench, loom, node shaper(slab n stairs n such), smelter, pottery kiln, dye pot, ...
registration of such
consider spliting the registration of such stations to it's own mod,
but at minimum it's own file

forspec for the stations and for players hand crafting

crafting itself

crafting helper functions


functions
	get recipes(crafter, crafting station pos?)
	get available inputs(crafter)
	get how many craftabale(inputs, recipe)
		return [amount| partially | Not at all]

	craft(crafter, recipe, count)
		return consumed resources, created resources
	apply changes(crafter, consumed resources, created resources)


USE:
player clicks crafting station or inv button
crafting formspec opens up,
formspec shows reciepes that
 	the player can currently craft
	the player has at least one component of
	-- has no component of?
		instead a button that switches to a formspec that shows all recipes at given station?
	maybe button that toggles between showing crafteable, partial, and all recipes?


player selects recipe
	recipe is displayed in detail
player selects amount
	selected amount of recipe is crafted
		items are removed/added to inventory as necessary
			excess is dropped on floor

after each button press

TODO: optional dependency on invchange detection, update players crafting formspec

]]
