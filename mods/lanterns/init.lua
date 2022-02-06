local modname = minetest.get_current_modname()

-- TODO: split in two parts: one for placing the light node; one for determining it's strength
-- that way it's easier to add other sources of caried light

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
    on_timer = function(pos)
        minetest.remove_node(pos)
    end,
}

for i = 1, minetest.LIGHT_MAX do
    local light_def = table.copy(glowing_air)
    light_def.light_source = i
    minetest.register_node("lanterns:light_" .. i, light_def)
end

local orig_get = sfinv.pages["sfinv:crafting"].get
sfinv.override_page("sfinv:crafting", {
    get = function(self, player, context)
        local fs = orig_get(self, player, context)
        return fs .. "list[current_player;lantern;0,3;1,1]"
    end
})

minetest.register_on_joinplayer(
    function(player)
        local inv_ref = player:get_inventory()
        inv_ref:set_size("lantern", 1)
    end
)

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
    for _, player in pairs(minetest.get_connected_players()) do
        local lantern_item = player:get_inventory():get_stack("lantern", 1)
        if lantern_item:is_empty() then return end
        lantern_item = lantern_item:get_name()
        local lantern_def = minetest.registered_nodes[lantern_item]
        if not lantern_def or lantern_def.light_source == 0 then
            return
        end
		place_light(player, lantern_def.light_source)
    end
end)
