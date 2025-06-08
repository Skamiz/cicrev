
c_recipes.registered_recipes = {}
c_recipes.recipes_by_input = {}
c_recipes.recipes_by_output = {}
c_recipes.recipes_by_group = {}

local game_running = false
core.after(0, function() game_running = true end)

local bad_modname = "Recipe name must follow 'mod_name:recipe_name' format. Was instead '%s'"
local already_registered = "Failed to register recipe as recipe '%s' already exists."
c_recipes.register_recipe = function(name, def)
	local mod_origin = core.get_current_modname()
	local mod_name = name:match("([^:%s]+):")
	assert(mod_name == mod_origin, bad_modname:format(name))

	if c_recipes.registered_recipes[name] then
		core.log("warning", already_registered:format(name))
		return false
	end

	def.name = name
	def.mod_origin = mod_origin
	def.image = def.image or next(def.outputs) or "blank.png"
	def.description = def.description or ""
	def.inputs = def.inputs or {}
	def.outputs = def.outputs or {}
	def.groups = def.groups or {}

	c_recipes.registered_recipes[name] = def

	if game_running then
		c_recipes.resolve_recipe_aliases(def)
		c_recipes.cache_recipe(def)
	end

	return true
end

local nonexistent_recipe = "Failed to unregister recipe '%s' as no such recipe is registered."
c_recipes.unregister_recipe = function(name)
	if not c_recipes.registered_recipes[name] then
		core.log("warning", nonexistent_recipe:format(name))
		return false
	end

	c_recipes.registered_recipes[name] = nil

	if game_running then
		c_recipes.regenerate_caches()
	end

	return true
end

-- c_recipes.get_recipes_by_inputs = function(inputs)
-- 	return recipes
-- end
--
-- c_recipes.get_recipes_by_outputs = function(outputs)
-- 	return recipes
-- end

c_recipes.get_filtered_recipes = function(filter)
	local recipes = {}
	for name, def in pairs(c_recipes.registered_recipes) do
		if filter(def) then
			recipes[name] = def
		end
	end

	return recipes
end

-- aliases
-- TODO: test this
c_recipes.resolve_alias = function(name)
	while core.registered_aliases[name] do
		name = core.registered_aliases[name]
	end
	return name
end

local nonexistent_item = "Recipe '%s' uses item '%s', which doesn't exist."
c_recipes.resolve_recipe_aliases = function(recipe)
	for input, amount in pairs(recipe.inputs) do
		local new_input = c_recipes.resolve_alias(input)

		if new_input ~= input then
			recipe.inputs[input] = nil
			recipe.inputs[new_input] = (recipe.inputs[new_input] or 0) + amount
		end

		-- if not core.registered_items[new_input] then
		-- 	core.log("warning", nonexistent_item:format(recipe.name, new_input))
		-- end
	end
	for output, amount in pairs(recipe.outputs) do
		local new_output = c_recipes.resolve_alias(output)

		if new_output ~= output then
			recipe.outputs[output] = nil
			recipe.outputs[new_output] = (recipe.outputs[new_output] or 0) + amount
		end

		-- if not core.registered_items[new_output] then
		-- 	core.log("warning", nonexistent_item:format(recipe.name, new_output))
		-- end
	end
end

c_recipes.resolve_all_aliases = function()
	for name, def in pairs(c_recipes.registered_recipes) do
		c_recipes.resolve_recipe_aliases(def)
	end
end

-- caching
c_recipes.cache_recipe = function(recipe)
	for input, amount in pairs(recipe.inputs) do
		if not c_recipes.recipes_by_input[input] then
			c_recipes.recipes_by_input[input] = {}
		end
		c_recipes.recipes_by_input[input][recipe.name] = recipe
	end
	for output, amount in pairs(recipe.outputs) do
		if not c_recipes.recipes_by_output[output] then
			c_recipes.recipes_by_output[output] = {}
		end
		c_recipes.recipes_by_output[output][recipe.name] = recipe
	end
	for group, value in pairs(recipe.groups) do
		if not c_recipes.recipes_by_group[group] then
			c_recipes.recipes_by_group[group] = {}
		end
		if value ~= 0 then
			c_recipes.recipes_by_group[group][recipe.name] = recipe
		end
	end
end

c_recipes.regenerate_caches = function()
	c_recipes.recipes_by_input = {}
	c_recipes.recipes_by_output = {}
	c_recipes.recipes_by_group = {}

	for name, def in pairs(c_recipes.registered_recipes) do
		c_recipes.cache_recipe(def)
	end
end


local function finalize()
	c_recipes.resolve_all_aliases()
	c_recipes.regenerate_caches()
end

-- TODO: either or
-- core.after(0, finalize)
core.register_on_mods_loaded(finalize)
