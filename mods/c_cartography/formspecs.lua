local cartography = cartography

-- cartography.build_image = function(image_data, width, height)
-- 	return "[png:" .. core.encode_base64(core.encode_png(width, height, image_data))
-- end



local function get_tabs(current)
	current = current or 1
	return "tabheader[0,0;0.5;tab_bar;" .. table.concat(cartography.page_names, ",") .. ";" .. current .. ";true;false]"
end

local function build_page_fs(page_name)
	local page_def = cartography.registered_pages[page_name]
	local page_content = "label[0,0.5;Page can't be loaded due to missing data maps.]"
	if cartography.util.depends_fulfilled(page_def.depends, cartography.registered_data_maps) then
		page_content = page_def:get_page_fs(cartography.registered_data_maps)
	end

	local fs = {
		"formspec_version[9]",
		"size[11,11]",
		"padding[0,0]",
		"no_prepend[]",
		-- "bgcolor[;neither;]",
		"bgcolor[;true;]",
		"background[0,0;11,11;c_cartography_map_background.png;false]",
		"label[0.5,0.3;" .. page_def.description .. "]",
		get_tabs(page_def.tab),
		"container[0.5,0.5]",
			page_content,
		"container_end[]",
	}

	return table.concat(fs)
end

cartography.show_page = function(player, page_name)
	local page_fs = build_page_fs(page_name)
	core.show_formspec(player:get_player_name(), cartography.modname .. ":page", page_fs)
end


cartography.show_maps = function(player)
	local page_name = cartography.page_names[1]
	cartography.show_page(player, page_name)
end



core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= cartography.modname .. ":page" then return end
	local tab = tonumber(fields.tab_bar)
	if tab then
		local page_name = cartography.page_names[tab]
		cartography.show_page(player, page_name)
	end
	-- print(dump(fields))
end)
