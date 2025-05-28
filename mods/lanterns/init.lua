local modname = minetest.get_current_modname()

-- TODO: split in two parts: one for placing the light node; one for determining it's strength
-- that way it's easier to add other sources of caried light


-- DEFINITIONS

local glowing_air = {
    description = "glowing air",
	drawtype = "airlike",
	paramtype = "light",
	groups = {not_in_creative_inventory=1, glowing_air = 1},
	sunlight_propagates = true,
	can_dig = false,
	walkable = false,
	buildable_to = true,
	-- light_source = minetest.LIGHT_MAX,
    pointable = false,
	air_equivalent = true,
    on_timer = function(pos)
        minetest.remove_node(pos)
    end,
}

for i = 1, minetest.LIGHT_MAX do
    local light_def = table.copy(glowing_air)
	light_def.description = light_def.description .. " " .. i
    light_def.light_source = i
    light_def.inventory_image = "lanterns_light_" .. i .. ".png"
    minetest.register_node("lanterns:light_" .. i, light_def)
end




-- INVENTORY

local players_with_lantern = {}
local function check_lantern_slot(player)
	local lantern = player:get_inventory():get_stack("lantern", 1)
	local def = core.registered_items[lantern:get_name()]
	if def and def.light_source and def.light_source > 0 then
		players_with_lantern[player] = def.light_source
	else
		players_with_lantern[player] = nil
	end
end

minetest.register_on_joinplayer(function(player)
	local inv_ref = player:get_inventory()
	inv_ref:set_size("lantern", 1)

	check_lantern_slot(player)
end)

core.register_allow_player_inventory_action(function(player, action, inventory, inventory_info)
	if inventory_info.listname == "lantern"	or inventory_info.to_list == "lantern" then
		local item

		if action == "move" then
			item = inventory:get_stack(inventory_info.from_list, inventory_info.from_index)
		elseif action == "put" then
			item = inventory_info.stack
		end

		local def = core.registered_items[item:get_name()]
		if def and def.light_source and def.light_source > 0 then
			return 1
		else
			return 0
		end
	end
end)
core.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
	if inventory_info.listname == "lantern"
			or inventory_info.to_list == "lantern"
			or inventory_info.from_list == "lantern" then
		check_lantern_slot(player)
	end
end)

-- GAMEPLAY

local function can_place_light(pos)
	local node_name = minetest.get_node(pos).name
	return node_name == "air" or minetest.get_item_group(node_name, "glowing_air") > 0
end

local function get_light_pos(player)
	local pos = player:get_pos()
	pos = vector.round(pos)
	if can_place_light(pos) then return pos end
	pos.y = pos.y + 1
	if can_place_light(pos) then return pos end
	pos = minetest.find_node_near(pos, 1, {"air", "group:glowing_air"})
	return pos
end


local players = {}
local function place_light(player, level)
	local player_name = player:get_player_name()
	local old_pos = players[player_name]
	local pos = get_light_pos(player)

	if not pos then
		if old_pos then minetest.remove_node(old_pos) end
		players[player_name] = nil
		return
	end

	minetest.set_node(pos, {name = "lanterns:light_" .. level})

	if old_pos and not vector.equals(pos, old_pos) then
		minetest.remove_node(old_pos)
	end

	players[player_name] = pos
	minetest.get_node_timer(pos):start(1)
end

minetest.register_globalstep(function(dtime)
    for player, light_source in pairs(players_with_lantern) do
		place_light(player, light_source)
    end
end)


-- SFINV INTEGRATION

local orig_get = sfinv.pages["sfinv:crafting"].get
sfinv.override_page("sfinv:crafting", {
    get = function(self, player, context)
        local fs = orig_get(self, player, context)
        return fs .. "list[current_player;lantern;0.25,4;1,1]"
    end
})
