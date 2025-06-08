--[[
recipe list(recipe list)
	return fs recipe list, fs scrollbar??

open crafting formspec( carfting station, pos?)

show_player_crafting_formspec(player, context)

context = {
	crafting_station
}
button_specifiers{
	{name = "dsfsd", type = image/item, image = texture.png, description = "foobar", style?}
}
item_image_button[<X>,<Y>;<W>,<H>;<item name>;<name>;<label>]
image_button[<X>,<Y>;<W>,<H>;<texture name>;<name>;<label>]
tooltip[<gui_element_name>;<tooltip_text>;<bgcolor>;<fontcolor>]
]]
c_crafting.formspecs = {}
local formspecs = c_crafting.formspecs
local crafting_formspecs = formspecs

local image_button = "image_button[%s,%s;1,1;%s;%s;]"
local item_image_button = "item_image_button[%s,%s;1,1;%s;%s;]"
local tooltip = "tooltip[%s;%s]"
local style_craftable = "style_type[image_button,item_image_button;bgimg=c_crafting_button_craftable.png;border=false;bgimg_middle=4;padding=-4]"
-- local style_craftable = "style_type[item_image_button;bgimg=c_crafting_button_craftable.png;border=false;bgimg_middle=4;padding=-4]"
local style_uncraftable = "style_type[image_button,item_image_button;bgimg=c_crafting_button_uncraftable.png;border=false;bgimg_middle=4;padding=-4]"
-- local style_uncraftable = "style_type[item_image_button;bgimg=c_crafting_button_uncraftable.png;border=false;bgimg_middle=4;padding=-4]"
local style_super_uncraftable = "style_type[image_button,item_image_button;bgimg=c_crafting_button_hidden.png;border=false;bgimg_middle=4;padding=-4]"
local function make_crafting_button_grid_fs(button_specifiers, columns, scroll_value)
	local fs = {}
	-- fs[#fs + 1] = "scrollbaroptions[opt1;opt2;...]"
	fs[#fs + 1] = "scrollbar[5.25,0;0.5,5;vertical;scroll_name;" .. (scroll_value or 0) .. "]"
	fs[#fs + 1] = "scroll_container[0,0;5,5;scroll_name;vertical;0.1;0]"
	for i, button in ipairs(button_specifiers) do
		local x_pos = (i - 1) % columns
		local y_pos = math.floor((i - 1) / columns)

		-- button style
		if button.craft_count > 0  then
			fs[#fs + 1] = style_craftable:format(button.name)
		elseif button.craft_count == 0 then
			fs[#fs + 1] = style_uncraftable:format(button.name)
		else
			fs[#fs + 1] = style_super_uncraftable:format(button.name)
		end

		-- button itself
		if not button.image:find(".png") then
			fs[#fs + 1] = item_image_button:format(x_pos, y_pos, button.image, button.name)
		else
			fs[#fs + 1] = image_button:format(x_pos, y_pos, button.image, button.name)
		end

		-- button tooltip
		fs[#fs + 1] = tooltip:format(button.name, button.description)
	end
	fs[#fs + 1] = "scroll_container_end[]"
	return table.concat(fs)
end

local pixel = 1/64
local function get_item_image_fs(x_pos, y_pos, item, count)
	local fs = {}
	if core.registered_items[item] then
		fs[#fs + 1] = "item_image[" .. x_pos .. "," .. y_pos .. ";1,1;" .. item .. "]"
		fs[#fs + 1] = "tooltip[" .. x_pos .. "," .. y_pos .. ";1,1;" .. core.registered_items[item].description .. "]"

		if count and count > 9 then
			fs[#fs + 1] = "label[" .. x_pos + 46 * pixel .. "," .. y_pos + 54 * pixel .. ";" .. count .. "]"
		elseif count and count > 1 then
			fs[#fs + 1] = "label[" .. x_pos + 55 * pixel .. "," .. y_pos + 54 * pixel .. ";" .. count .. "]"
		end
	-- elseif item:find(".png") then
	end
	return table.concat(fs)
end

crafting_formspecs.get_recipe_fs = function(recipe)
	local fs = {}

	local n = 0
	for item, count in pairs(recipe.outputs) do
		fs[#fs + 1] = get_item_image_fs(n, 0, item, count)
		n = n + 1
	end
	local n = 0
	for item, count in pairs(recipe.inputs) do
		local x_pos = (n % 4)
		local y_pos = math.floor(n / 4) + 1.5
		fs[#fs + 1] = get_item_image_fs(x_pos, y_pos, item, count)
		n = n + 1
	end

	fs = table.concat(fs)
	return fs
end

-- buttons which initiate crafting action
-- usually {1, 5, 25, 100, 'max'}
formspecs.get_craft_buttons = function(craft_sizes)
	local fs = {}

	if craft_sizes then
		for i = 1, 5 do
			fs[#fs + 1] = "box[0," .. (i-1) * 0.75 .. ";0.5,0.5;#0000]"
			fs[#fs + 1] = "button[0," .. (i-1) * 0.75 .. ";0.5,0.5;craft_" .. craft_sizes[i] .. ";" .. craft_sizes[i] .. "]"
			fs[#fs + 1] = "tooltip[craft_" .. craft_sizes[i] .. ";" .. "Craft " .. craft_sizes[i] .. "]"
		end
		fs[#fs - 1] = "button[0," .. (4) * 0.75 .. ";0.5,0.5;craft_" .. math.max(0, craft_sizes[5]) .. ";" .. math.max(0, craft_sizes[5]) .. "]"
		fs[#fs] = "tooltip[craft_" .. math.max(0, craft_sizes[5]) .. ";" .. "Craft Maximum]"
	else
		for i = 1, 5 do
			fs[#fs + 1] = "box[0," .. (i-1) * 0.75 .. ";0.5,0.5;#0000]"
			fs[#fs + 1] = "button[0," .. (i-1) * 0.75 .. ";0.5,0.5;dummy_button;x]"
		end
	end
	return table.concat(fs)
end




local function button_sort(a, b)
	local ca, cb = math.sign(a.craft_count), math.sign(b.craft_count)
	if ca == cb then
		return a.name < b.name
	end
	return a.craft_count > b.craft_count
end

local function get_craft_button_list(crafting_data)
	local recipes = crafting_data.available_recipes
	local craft_counts = crafting_data.craft_counts
	local shown_recipes = crafting_data.shown_recipes

	local min = -1
	if shown_recipes == "uncraftable" then
		min = 0
	elseif shown_recipes == "craftable" then
		min = 1
	end

	local button_list = {}
	for r_name, craft_count in pairs(craft_counts) do
		if craft_count >= min then
			local recipe = recipes[r_name]
			local button = {
				craft_count = craft_count,
				name = r_name,
				image = recipe.image,
				description = recipe.description,
			}
			table.insert(button_list, button)
		end
	end

	table.sort(button_list, button_sort)

	return button_list
end

local function get_crafting_formspec(recipe_button_list, recipe, craft_sizes, scroll_value)
	local recipe_selector = make_crafting_button_grid_fs(recipe_button_list, 5, scroll_value)
	local recipe_display = recipe and formspecs.get_recipe_fs(recipe) or ""
	local craft_buttons = formspecs.get_craft_buttons(craft_sizes) or ""

	-- TODO: split this into multiple functions
	-- 1) get crafting part
	-- 2) get player inv part
	-- 3) assemble
	local fs = {
		"formspec_version[9]",
		"size[13.25,12]",
		"padding[0,0]",
		"container[0.5,0.5]",
			"container[7.0,0.0]",
				"%s", --recipe_display
			"container_end[]",
			"container[11.75,0.0]",
				"%s", --craft_buttons
			"container_end[]",
			"list[current_player;main;0,6.25;10,4]",
			"image_button[0,0;1,1;c_crafting_recipe_visibility.png;toggle_recipe_visibility;]",
			"tooltip[toggle_recipe_visibility;Toggle whether uncraftable recipes are shown in the list.]",

			"container[1.0,0.0]",
				"%s", --recipe_selector
			"container_end[]",
		"container_end[]",
	}

	fs = table.concat(fs)
	fs = fs:format(recipe_display, craft_buttons, recipe_selector)

	return fs
end

local players = c_crafting.crafting_players


formspecs.stop_player_crafting = function(player)
	players[player] = nil
	core.close_formspec(player:get_player_name(), "c_crafting:crafting")
end


formspecs.update_crafting_formspec = function(player)
	local crafting_data = players[player]
	assert(crafting_data)

	c_crafting.update_craft_counts(crafting_data)

	local recipe_button_list = get_craft_button_list(crafting_data)
	local recipe
	local craft_sizes

	if crafting_data.selected_recipe then
		recipe = crafting_data.available_recipes[crafting_data.selected_recipe]
		craft_sizes = {1, 5, 25, 100, crafting_data.craft_counts[crafting_data.selected_recipe]}
	end

	local fs = get_crafting_formspec(recipe_button_list, recipe, craft_sizes, crafting_data.scroll_value)
	core.show_formspec(player:get_player_name(), "c_crafting:crafting", fs)
end

local function set_recipe_visibility(player, visible)
	local meta = player:get_meta()
	meta:set_string("c_crafting_shown_recipes", visible)

	local p_data = players[player]
	if p_data then
		p_data.shown_recipes = visible

		formspecs.update_crafting_formspec(player)
	end
end

local function toggle_recipe_visibility(player)
	local meta = player:get_meta()
	local visible = meta:get("c_crafting_shown_recipes") or "uncraftable"

	if visible == "uncraftable" then
		set_recipe_visibility(player, "all")
	elseif visible == "all" then
		set_recipe_visibility(player, "craftable")
	elseif visible == "craftable" then
		set_recipe_visibility(player, "uncraftable")
	end
end

local function set_selceted_recipe(player, r_name)
	local p_data = players[player]
	p_data.selected_recipe = r_name

	formspecs.update_crafting_formspec(player)
end


core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "c_crafting:crafting" then return end
	-- print(dump(fields))

	local crafting_data = players[player]

	if fields.toggle_recipe_visibility then
		toggle_recipe_visibility(player)
		return true
	end

	for r_name, _ in pairs(fields) do
		if c_recipes.registered_recipes[r_name] then
			set_selceted_recipe(player, r_name)
			return true
		end
	end

	for field, _ in pairs(fields) do
		local craft_count = tonumber(field:match("^craft_(%d+)"))

		if craft_count and craft_count > 0 then
			local crafter = crafting_data.crafter
			local crafting_station = crafting_data.crafting_station
			local recipe = crafting_data.available_recipes[crafting_data.selected_recipe]

			c_crafting.try_craft(crafter, crafting_station, recipe, craft_count)

			return true
		end
	end

	if fields.scroll_name then
		local e = core.explode_scrollbar_event(fields.scroll_name)
		if e.type == "CHG" then
			crafting_data.scroll_value = e.value
		end
		return true
	end

	if fields.quit then
		formspecs.stop_player_crafting(player)
		return true
	end
end)
