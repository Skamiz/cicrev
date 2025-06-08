--[[


]]

c_crafting.crafting_players = {
	--[[
	crafting_data = { -- formely p_data
		crafting_station = crafting_station,
		available_recipes = recipes,
		craft_counts,
		shown_recipes = "craftable/uncraftable/all",

		selected_recipe = recipe_name,
	}
	]]
}
local players = c_crafting.crafting_players


-- UNSORTED

c_crafting.try_craft = function(crafter, crafting_station, recipe, craft_count)
	local crafting_def = crafting_station.crafting_def

	craft_count = math.min(craft_count, crafting_def.get_craft_count(recipe, crafting_def.get_input_list(crafter, crafting_station)))
	if craft_count > 0 then

		local consumed, created = crafting_def.get_craft_result(recipe, craft_count)
		crafting_def.apply_craft_result(crafter, crafting_station, consumed, created)

		c_crafting.formspecs.update_crafting_formspec(crafter)
	end
end

-- CRAFTING STATION

-- close formspecs of players using destroyed crafting station
c_crafting.after_crafting_station_destruct = function(pos, oldnode)
	for player, crafting_data in pairs(c_crafting.crafting_players) do
		if pos == crafting_data.crafting_station.pos then
			c_crafting.formspecs.stop_player_crafting(player)
		end
	end
end

-- get players "main" inventory as an available_inputs list
c_crafting.get_player_inventory = function(crafter, crafting_station)
	local inv = crafter:get_inventory()
	local main = inv:get_list("main")
	local inputs = {}
	for i, itemstack in ipairs(main) do
		local name = itemstack:get_name()
		local count = itemstack:get_count()
		inputs[name] = (inputs[name] or 0) + count
	end
	return inputs
end

-- how often a recipe can be made with given inputs
-- returns count, 0 if only partially craftable or -1 if not at all
c_crafting.get_craft_count = function(recipe, inputs)
	local required = recipe.inputs
	local max = math.huge
	local partial = false
	for name, count in pairs(required) do
		local have = (inputs[name] or 0) / count
		if have > 0 then partial = true end
		max = math.min(max, have)
	end

	local count = math.floor(max)
	if count == 0 and not partial then
		count = -1
	end

	return count
end

-- default implementation for get_craft_result
c_crafting.get_craft_result = function(recipe, count)
	local consumed, created = {}, {}

	for input, amount in pairs(recipe.inputs) do
		consumed[input] = amount * count
	end
	for output, amount in pairs(recipe.outputs) do
		created[output] = amount * count
	end

	return consumed, created
end

-- takes from and puts into, the crafters "main" inventory list
c_crafting.apply_craft_result = function(crafter, crafting_station, consumed, created)
	local inv = crafter:get_inventory()
	for item, amount in pairs(consumed) do
		inv:remove_item("main", ItemStack(item .. " " .. amount))
	end
	for item, amount in pairs(created) do
		inv:add_item("main", ItemStack(item .. " " .. amount))
	end
end

-- CRAFTING FORMSPEC

local function get_craft_counts(recipes, inputs, comparation_func)
	local craft_counts = {}
	for r_name, r_def in pairs(recipes) do
		craft_counts[r_name] = comparation_func(r_def, inputs)
	end
	return craft_counts
end

c_crafting.update_craft_counts = function(crafting_data)
	local crafting_def = crafting_data.crafting_station.crafting_def
	local available_inputs = crafting_def.get_input_list(crafting_data.crafter, crafting_data.crafting_station)
	local craft_counts = get_craft_counts(crafting_data.available_recipes, available_inputs, crafting_def.get_craft_count)

	crafting_data.craft_counts = craft_counts
end

local function set_up_crafting_data(player, crafting_station)
	local crafting_data = {
		crafter = player,
		crafting_station = crafting_station,
		available_recipes = crafting_station.crafting_def.get_recipes(player, crafting_station) or {},
		shown_recipes = player:get_meta():get("c_crafting_shown_recipes") or "uncraftable",
	}

	c_crafting.update_craft_counts(crafting_data)

	players[player] = crafting_data
end

c_crafting.initiate_crafting = function(player, crafting_station)
	set_up_crafting_data(player, crafting_station)

	c_crafting.formspecs.update_crafting_formspec(player)
end
