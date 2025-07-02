if not fast_craft then return end
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local name_prefix = modname .. ":"

local function item_name(name)
	return name_prefix .. name
end

if not c_recipes then return end

c_recipes.register_recipe(item_name("ingot_copper"), {
	description = "Copper Ingot",
	outputs = {[item_name("ingot_copper")] = 1,},
	inputs = {[item_name("ore_native_copper")] = 1,},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("ingot_iron"), {
	description = "Iron Ingot",
	outputs = {[item_name("ingot_iron")] = 1,},
	inputs = {[item_name("ore_hematite")] = 1,},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("ingot_steel"), {
	description = "Steel Ingot",
	outputs = {[item_name("ingot_steel")] = 3,},
	inputs = {
		[item_name("ore_hematite")] = 3,
		[item_name("ore_native_platinum")] = 1,
	},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("ingot_platinum"), {
	description = "Platinum Ingot",
	outputs = {[item_name("ingot_platinum")] = 1,},
	inputs = {[item_name("ore_native_platinum")] = 2,},
	groups = {crafting_smelt = 1},
})

c_recipes.register_recipe(item_name("block_copper"), {
	description = "Copper Block",
	outputs = {[item_name("block_copper")] = 1,},
	inputs = {[item_name("ingot_copper")] = 8,},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("block_iron"), {
	description = "Iron Block",
	outputs = {[item_name("block_iron")] = 1,},
	inputs = {[item_name("ingot_iron")] = 8,},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("block_steel"), {
	description = "Steel Block",
	outputs = {[item_name("block_steel")] = 1,},
	inputs = {[item_name("ingot_steel")] = 8,},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("block_platinum"), {
	description = "Platinum Block",
	outputs = {[item_name("block_platinum")] = 1,},
	inputs = {[item_name("ingot_platinum")] = 8,},
	groups = {crafting_smelt = 1},
})

c_recipes.register_recipe(item_name("ingot_copper_8"), {
	description = "Copper Ingots",
	outputs = {[item_name("ingot_copper")] = 8,},
	inputs = {[item_name("block_copper")] = 1,},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("ingot_iron_8"), {
	description = "Iron Ingots",
	outputs = {[item_name("ingot_iron")] = 8,},
	inputs = {[item_name("block_iron")] = 1,},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("ingot_steel_8"), {
	description = "Steel Ingots",
	outputs = {[item_name("ingot_steel")] = 8,},
	inputs = {[item_name("block_steel")] = 1,},
	groups = {crafting_smelt = 1},
})
c_recipes.register_recipe(item_name("ingot_platinum_8"), {
	description = "Platinum Ingots",
	outputs = {[item_name("ingot_platinum")] = 8,},
	inputs = {[item_name("block_platinum")] = 1,},
	groups = {crafting_smelt = 1},
})
