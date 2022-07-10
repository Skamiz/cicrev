--[[
Fast Craft by Skamiz Kazzarch

See: https://forum.minetest.net/viewtopic.php?f=9&t=28125 for a more generic version of this mod

WARNING: Is liable to be buggy in case of recipes, which ask for a group ingredient,
 but also a specific item belonging to the group, since I didn't figure out a way
 to correctly count the items in such a case.


WARNING: Fails if recipe defines replacements for specific items which are only
requested by group
	example: recipe asks for group water bucket, and specifies two replacements
	one in case of normal water and one in case of river water,
	both of which replace with empty bucket
	this mod will give two empty buckets when the recipe is crafted



- only once there is an active need
TODO: if an item is required, but imediately returned count it as if infinite
TODO: fake scrollbar which can be styled
try: can I just place images over the scrollbar and still have it work?
TODO: button clikcing sounds
TODO: maybe do somehting about all that string concatation?
TODO: callbacks for crafting stuff
TODO: pressetes for group icons



---------------------------------------------



Wish for minetest: a callback for when inventory is opened/contents are changed
--]]

-- SETUP STUFF

local t0 = minetest.get_us_time()

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

fast_craft = {}
fast_craft.registered_crafts = {}
local registered_crafts = fast_craft.registered_crafts

-- just a usefull debug function
local function print_table(po)
	for k, v in pairs(po) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end

local S = minetest.get_translator("fast_craft")
local pixel = 1/64 -- in terms of inventory slots this coresponds to one pixel



local group_icons = {
	planks = "cicrev:planks_oak",
	log = "cicrev:log_oak",
}

local craft_sizes = {1, 5, 25, 99}

-- helper function
-- local function crafting_bench_nearby(player)
-- 	local p_pos = player:get_pos():round()
--     p_pos.y = p_pos.y + 1
--
-- 	return minetest.find_node_near(p_pos, 3, {"mcl_crafting_table:crafting_table"}, true)
-- end


-- RECIPE REGISTRATION

-- helps to filter out duplicate recipes
local function recipe_to_string(recipe)
	local rs = "o:" .. recipe.output[1] .. " " .. recipe.output[2] .. "a:"
	for item, count in pairs(recipe.additional_output) do
		rs = rs .. item .. " " .. count .. ","
	end
	rs = rs .. "i:"
	for item, count in pairs(recipe.input) do
		rs = rs .. item .. " " .. count .. ","
	end
	-- not checking for condition

	return rs
end

local recipe_strings = {}

function fast_craft.register_craft(recipe)
	-- TODO: some validation that all the involved items exist, if not -> warning

	if not recipe.output[2] then recipe.output[2] = 1 end
	if not recipe.additional_output then recipe.additional_output = {} end

	local rs = recipe_to_string(recipe)
	if not recipe_strings[rs] then
		recipe_strings[rs] = true
		recipe.output.def = minetest.registered_items[recipe.output[1]]
		registered_crafts[#registered_crafts + 1] = recipe
	end
end

minetest.register_on_mods_loaded(function()
	for item, def in pairs(minetest.registered_items) do
		for group, level in pairs(def.groups or {}) do
			if not group_icons[group] then group_icons[group] = item end
		end
	end
end)


-- FUNCTIONAL PART

-- simplify the inventory to a '[item_name] = amount' table
local function inv_to_table(inv)
	local t = {}
	for _, stack in pairs(inv:get_list("main")) do
		if not stack:is_empty() then
			local name, count = stack:get_name(), stack:get_count()
			if not t[name] then t[name] = 0 end
			t[name] = t[name] + count
		end
	end
	return t
end

-- returns number of times recipe can be crafted from inventory
local function can_craft(recipe, inv)
	local n = 999
	for item, count in pairs(recipe.input) do
		-- some items could be counted twice here, see warning
		if item:find("group") then
			local groups = item:sub(7, -1):split()

			local total = 0
			for inv_item, inv_count in pairs(inv) do
				local suitable = true
				for _, group in pairs(groups) do
					if minetest.get_item_group(inv_item, group) == 0 then
						suitable = false
					end
				end
				if suitable then
					total = total + inv_count
				end
			end
			n = math.min(n, math.floor(total / count))
		else
			n = math.min(n, math.floor((inv[item] or 0) / count))
		end
	end

	return n
end

-- returns array of recipe indexex, the player can craft
-- checks for custom condition
local function get_craftable_recipes(player)
	local r = {}
	local inv = inv_to_table(player:get_inventory())

	for i, recipe in ipairs(registered_crafts) do
		if can_craft(recipe, inv) > 0 and ((not recipe.condition) and true or recipe.condition(player)) then
			r[#r + 1] = i
		end
	end

	return r
end

-- try to craft the recipe up to 'amount' times
-- actual item count depends on recipe output count
local function craft(player, recipe_index, amount)
	local recipe = registered_crafts[recipe_index]
	local inv = player:get_inventory()
	local inv_list = inv_to_table(inv)

	amount = math.min(amount, can_craft(recipe, inv_list))
	if amount == 0 then return end
	if recipe.condition and not recipe.condition(player) then return end

	-- taking input
	for in_item, count in pairs(recipe.input) do
		local total = count * amount
		-- some items could be counted twice here, see warning
		if in_item:find("group") then
			local groups = in_item:sub(7, -1):split()

			for inv_item, inv_count in pairs(inv_list) do
				local suitable = true
				for _, group in pairs(groups) do
					if minetest.get_item_group(inv_item, group) == 0 then
						suitable = false
					end
				end
				if suitable then
					local taken = inv:remove_item("main", inv_item .. " " .. total)
					total = total - taken:get_count()
					if total == 0 then break end
				end
			end
		else
			inv:remove_item("main", in_item .. " " .. total)
		end
	end

	-- givin ouput
	local pos = player:get_pos()
	local total = recipe.output[2] * amount
	local stack_max = recipe.output.def.stack_max
	-- is split up to avoid overly large itemstacks
	for i = 1, math.floor(total / stack_max) do
		local leftover = inv:add_item("main", recipe.output[1] .. " " .. stack_max)
		minetest.add_item(pos, leftover)
	end
	local leftover = inv:add_item("main", recipe.output[1] .. " " .. total % stack_max)
	minetest.add_item(pos, leftover)

	-- additional outputs
	for item, count in pairs(recipe.additional_output) do
		print(item)
		local total = count * amount
		local stack_max = minetest.registered_items[item].stack_max
		for i = 1, math.floor(total / stack_max) do
			local leftover = inv:add_item("main", item .. " " .. stack_max)
			minetest.add_item(pos, leftover)
		end
		local leftover = inv:add_item("main", item .. " " .. total % stack_max)
		minetest.add_item(pos, leftover)
	end
end


-- FORMSPEC STUFF

-- recipe selection gui
local function get_recipe_list_fs(player, scroll_index)
	local recipes = get_craftable_recipes(player)

	local f = ""
		.. "container[0.25,0.25]"

	if #recipes > 16 then
		f = f .. "scrollbaroptions[max=" .. (math.floor(#recipes/4) * 10) - 30 .. "]"
		.. "scrollbar[4.25,0;0.5,4.75;vertical;scrlb;" .. (scroll_index or 0) .. "]"
		.. "scroll_container[0,0;4,4.75;scrlb;vertical;0.1]"
	end
	-- f = f .. "style_type[item_image_button;bgimg=crafting_select_button.png]"
	for i, craft_index in ipairs(recipes) do
		local x_pos = (i - 1) % 4
		local y_pos = math.floor((i - 1) / 4)
		local recipe = registered_crafts[craft_index]
		local item = recipe.output[1]
		local count = recipe.output[2] == 1 and "" or recipe.output[2]

		f = f .. "item_image_button[" .. x_pos .. "," .. y_pos .. ";1,1;" .. item .. ";recipe_" .. craft_index .. ";" .. count .. "]"
	end

	if #recipes > 16 then
		f = f .. "scroll_container_end[]"
	end
	f = f .. "container_end[]"

	return f
end

-- formspec string for item image and asociated item count
local function item_image_fs(x_pos, y_pos, item, count)
	local f = ""
	if item:find("group") then
		local groups = item:sub(7, -1):split()
		f = f .. "item_image[" .. x_pos .. "," .. y_pos .. ";1,1;" .. group_icons[groups[1]] .. "]"
		f = f .. "label[" .. x_pos + 0.390625 .. "," .. y_pos + 0.5 .. ";G]"
		f = f .. "tooltip[" .. x_pos .. "," .. y_pos .. ";1,1;" .. item .. ";#878787;#FFFFFF]"
	else
		f = f .. "item_image[" .. x_pos .. "," .. y_pos .. ";1,1;" .. item .. "]"
		f = f .. "tooltip[" .. x_pos .. "," .. y_pos .. ";1,1;" .. minetest.registered_items[item].description .. ";#878787;#FFFFFF]"
	end
	if count and count > 9 then
		f = f .. "label[" .. x_pos + 46 * pixel .. "," .. y_pos + 54 * pixel .. ";" .. count .. "]"
	elseif count and count > 1 then
		f = f .. "label[" .. x_pos + 55 * pixel .. "," .. y_pos + 54 * pixel .. ";" .. count .. "]"
	end
	return f
end

-- the main crafting formspec
local function get_craft_formspec(player, scroll_index, recipe_index)
	local f = ""
	.. "formspec_version[4]"
	.. "size[10.25,10.25]"
	-- .. "no_prepend[]"

	.. "bgcolor[;neither;]"
	.. "listcolors[#777777;#929292;#00000000]"
	.. "background[0,0;10.25,10.25;fc_background.png]"
	.. "style_type[button;bgimg=fc_button_8x8.png]"
	.. "style_type[image_button;bgimg=fc_button_8x8.png]"
	.. "style_type[item_image_button;bgimg=fc_button_16x16.png]"

	.. "list[current_player;main;0.25,5.25;8,4;]"
	.. "image_button[9.5,4.25;0.5,0.5;fc_reload.png;reload;;false;false]"
	.. "tooltip[reload;" .. S("Refresh Formspec") .. ";#878787;#FFFFFF]"

	f = f .. get_recipe_list_fs(player, scroll_index)

	if recipe_index then
		-- if a recipe is selected do stuff
		-- TODO: move this to it's own function
		local recipe = registered_crafts[recipe_index]
		local x_pos = 5.25
		local y_pos = 0.25
		f = f .. item_image_fs(5.25, 0.25, recipe.output[1], recipe.output[2])
		local n = 0
		for item, count in pairs(recipe.additional_output) do
			n = n + 1
			f = f .. item_image_fs(5.25 + n, 0.25, item, count)
		end
		n = 0
		for item, count in pairs(recipe.input) do
			local x_pos = (n % 4) + 5.25
			local y_pos = math.floor(n / 4) + 1.75
			f = f .. item_image_fs(x_pos, y_pos, item, count)
			n = n + 1
		end
		f = f .. "button[9.5,0.25;0.5,0.5;craft_" .. craft_sizes[1] .. "_" .. recipe_index .. ";" .. craft_sizes[1] .. "]"
		f = f .. "tooltip[craft_" .. craft_sizes[1] .. "_" .. recipe_index .. ";" .. S("Craft @1", craft_sizes[1]) .. ";#878787;#FFFFFF]"
		.. "button[9.5,1.;0.5,0.5;craft_" .. craft_sizes[2] .. "_" .. recipe_index .. ";" .. craft_sizes[2] .. "]"
		f = f .. "tooltip[craft_" .. craft_sizes[2] .. "_" .. recipe_index .. ";" .. S("Craft @1", craft_sizes[2]) .. ";#878787;#FFFFFF]"
		.. "button[9.5,1.75;0.5,0.5;craft_" .. craft_sizes[3] .. "_" .. recipe_index .. ";" .. craft_sizes[3] .. "]"
		f = f .. "tooltip[craft_" .. craft_sizes[3] .. "_" .. recipe_index .. ";" .. S("Craft @1", craft_sizes[3]) .. ";#878787;#FFFFFF]"
		.. "button[9.5,2.5;0.5,0.5;craft_" .. craft_sizes[4] .. "_" .. recipe_index .. ";" .. craft_sizes[4] .. "]"
		f = f .. "tooltip[craft_" .. craft_sizes[4] .. "_" .. recipe_index .. ";" .. S("Craft @1", craft_sizes[4]) .. ";#878787;#FFFFFF]"
		local max = can_craft(recipe, inv_to_table(player:get_inventory()))
		f = f .. "button[9.5,3.25;0.5,0.5;craft_" .. max .. "_" .. recipe_index .. "max;" .. max .. "]"
		f = f .. "tooltip[craft_" .. max .. "_" .. recipe_index .. "max;" .. S("Craft Maximum") .. ";#878787;#FFFFFF]"
	end

	return f
end

-- set players inventory formspec to fast_craft
local function set_fs(player, scroll_index, craft_index)
	if sfinv then
		local context = sfinv.get_or_create_context(player)
		player:set_inventory_formspec(
		get_craft_formspec(player, scroll_index, craft_index) ..
		sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx))
		-- this doesn't have acces to the interaction
		-- sfinv.set_page(player, "crafting:crafting")
	else
		player:set_inventory_formspec(get_craft_formspec(player, scroll_index, craft_index))
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- if formname ~= "" then return end
	-- print_table(fields)

	local _, _, scroll_index = (fields.scrlb or ""):find("VAL:(%d*)")

	-- sometimes the formspec needs to be updated manualy
	-- an explicit button helps convey that to the player
	if fields.reload then
		-- player:set_inventory_formspec(get_craft_formspec(player, scroll_index, craft_index))
		set_fs(player, scroll_index)
		return true
	end

	for k, v in pairs(fields) do
		-- recipe selected
		local _, _, craft_index = k:find("recipe_(%d*)")
		if craft_index then
			craft_index = tonumber(craft_index)
			set_fs(player, scroll_index, craft_index)
			return true
		end

		-- crafting button pressed
		local _, _, craft_amount, craft_index = k:find("craft_(%d*)_(%d*)")
		if craft_amount then
			craft_amount = tonumber(craft_amount)
			craft_index = tonumber(craft_index)
			craft(player, craft_index, craft_amount)

			set_fs(player, scroll_index, craft_index)
			return true
		end
	end

	-- if fields.scrlb then return true end
end)


-- OTHER STUFF

minetest.register_on_joinplayer(function(player, last_login)
	if not sfinv then
		player:set_inventory_formspec(get_craft_formspec(player))
	end
end)

minetest.register_chatcommand("fast_craft", {
	params = "",
	description = "Set inventory formspec to fact_craft.",
	privs = {},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		set_fs(player, scroll_index, craft_index)
		print_table(minetest.get_all_craft_recipes("mcl_stairs:stair_cobble")[1].items)
	end,
})


-- INTEGRATION

if sfinv then
	sfinv.register_page("fast_craft:crafting", {
	    title = S("Fast Craft"),
	    get = function(self, player, context)
            return get_craft_formspec(player) .. sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx)
	    end
	})
end

print("[MOD] 'fast_craft' loaded in " .. (minetest.get_us_time() - t0)/1000000 .. " s")
