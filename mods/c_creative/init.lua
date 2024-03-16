local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

--[[
creative hand item
add all nodes to 'everyting' group
TODO:
	creative priv
	button to toggle creative hand
	button to toggle item spam
	?button to toggle not_in_creative_inventory items
]]

c_creative = {}
c_creative.players_data = {}

dofile(modpath .. "/inventory.lua")
dofile(modpath .. "/gui.lua")

c_creative.get_player_data = function(player)
	local player_name = player:get_player_name()
	local data = c_creative.players_data[player_name]
	return data
end

local function setup_player_data(player)
	local player_name = player:get_player_name()
	local player_data = {
		filter_string = "",
		inv_index = 0,
		inv_size = nil,
		list_size = nil,
	}
	c_creative.players_data[player_name] = player_data
	c_creative.update_player_creative_list(player)
end
local function clear_player_data(player)
	local player_name = player:get_player_name()
	c_creative.players_data[player_name] = nil
	c_creative.inventory:set_size(player_name, 0)
end

minetest.register_on_joinplayer(setup_player_data)
minetest.register_on_leaveplayer(clear_player_data)
