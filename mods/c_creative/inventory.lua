--[[
functions:
	load all items
	get filtered list
		filter items by string
		filter items by group
	set filtered list to players creative inventory
	create detached inventory

]]
local function load_all_items()
	local all_items = {}
	for item, _ in pairs(minetest.registered_items) do
		table.insert(all_items, item)
	end
	table.sort(all_items)
	c_creative.all_items = all_items
end
minetest.register_on_mods_loaded(load_all_items)



local creative_inv_callbacks = {
	allow_move = function(inv, from_list, from_index, to_list, to_index, count, player)
		return 0
	end,
	allow_put = function(inv, listname, index, stack, player)
		return -1
	end,
	allow_take = function(inv, listname, index, stack, player)
		return -1
	end,
}
c_creative.inventory = minetest.create_detached_inventory("creative_items", creative_inv_callbacks)



-- list - table of items
local function set_player_creative_list(player, list)
	local player_data = c_creative.get_player_data(player)
	player_data.inv_size = #list

	local player_name = player:get_player_name()
	c_creative.inventory:set_size(player_name, #list + 1)
	c_creative.inventory:set_list(player_name, list)
end

function c_creative.update_player_creative_list(player)
	local meta = player:get_meta()
	local player_data = c_creative.get_player_data(player)
	local filter_string = meta:get_string("filter_string")

	local player_list = {}

	-- TODO: implement better filtereing
	for _, name in pairs(c_creative.all_items) do
		if (not minetest.registered_items[name].groups.not_in_creative_inventory) and
				name:find(filter_string) then
			table.insert(player_list, name)
		end
	end

	set_player_creative_list(player, player_list)
	player_data.inv_index = 0
end

function c_creative.set_player_filter_string(player, search)
	local meta = player:get_meta()
	meta:set_string("filter_string", search)

	c_creative.update_player_creative_list(player)
end
