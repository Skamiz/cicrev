--[[
keep track off:
	page
	search string
button to toggle creative hand
get formspec
	creative list
	navigation bar
	both

" ..  .. "
]]

local padding = 0.25
local font_width = 9/64

function c_creative.get_creative_widgets_fs(player, width)
	width = width or 8
	width = math.max(width, 6)

	local player_data = c_creative.get_player_data(player)

	local fs_width = width * (1 + padding) - padding
	local filter_string = player:get_meta():get_string("creative_filter_string")

	local inv_index = player_data.inv_index
	local inv_size = player_data.inv_size
	local list_size = player_data.list_size

	local max_pages = math.ceil(inv_size / list_size)
	local current_page = math.floor(inv_index / list_size) + 1
	local page_label = current_page .. " / " .. max_pages
	local digits = math.floor(math.log10(max_pages)) + 1

	local fs = {
		"field_close_on_enter[creative_filter;false]",
		"field[0,0;" .. 2 + padding .. ",0.75;creative_filter;;" .. filter_string .. "]",
		"tooltip[creative_search;Search]",
		"image_button[" .. 2 + padding .. ",0;0.75,0.75;c_creative_search.png;creative_search;]",
		"tooltip[creative_clear_search;Remove Filter]",
		"image_button[" .. 2 + padding + 1 .. ",0;0.75,0.75;c_creative_clear_search.png;creative_clear_search;]",
		"tooltip[creative_previous_page;Previous Page]",
		"image_button[" .. fs_width - 3.50 .. ",0;0.75,0.75;c_creative_previous_page.png;creative_previous_page;]",
		"label[" .. fs_width - 1.75 - digits*font_width .. ",0.375;" .. page_label .. "]",
		"tooltip[creative_next_page;Next Page]",
		"image_button[" .. fs_width - 0.75 .. ",0;0.75,0.75;c_creative_next_page.png;creative_next_page;]",
	}

	return table.concat(fs)
end

function c_creative.get_creative_list_fs(player, width, height)
	width = width or 8
	height = height or 4

	local player_data = c_creative.get_player_data(player)
	player_data.list_size = width * height

	local player_name = player:get_player_name()
	local start_index = player_data.inv_index

	local fs = "list[detached:creative_items;" .. player_name .. ";0,0;" .. width .. "," .. height .. ";" .. start_index .. "]"

	return fs
end

function c_creative.get_creative_inv_fs(player, width, height)
	width = width or 8
	height = height or 4

	local fs = {
		"container[0,1]",
			c_creative.get_creative_list_fs(player, width, height),
		"container_end[]",
		c_creative.get_creative_widgets_fs(player, width),
	}
	return table.concat(fs)
end




function c_creative.register_callback(form_name, callback)
	minetest.register_on_player_receive_fields(function(player, formname, fields)
		-- print("formname: " .. formname)
		-- print(dump(fields))
		if formname ~= form_name then return end

		if fields.creative_search or fields.key_enter_field == "creative_filter" then
			c_creative.set_player_filter_string(player, fields.creative_filter)
		end
		if fields.creative_clear_search then
			c_creative.set_player_filter_string(player, "")
		end
		local player_data = c_creative.get_player_data(player)
		if fields.creative_next_page then
			local new_index = player_data.inv_index + player_data.list_size
			if new_index > player_data.inv_size then
				new_index = 0
			end
			player_data.inv_index = new_index
		end
		if fields.creative_previous_page then
			local new_index = player_data.inv_index - player_data.list_size
			if new_index < 0 then
				new_index = math.floor(player_data.inv_size / player_data.list_size) * player_data.list_size
			end
			player_data.inv_index = new_index
		end
		callback(player)
	end)
end
