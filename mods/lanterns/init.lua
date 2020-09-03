local MODNAME = minetest.get_current_modname()

local glowing_air = {
    description = "glowing air",
	drawtype = "airlike",
	paramtype = "light",
	groups = {not_in_creative_inventory=1, glowing_air = 1},
	sunlight_propagates = true,
	can_dig = false,
	walkable = false,
	buildable_to = true,
	light_source = 10,
    pointable = false,
	selection_box = {
        type = "fixed",
        fixed = {0, 0, 0, 0, 0, 0}},
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

minetest.register_globalstep(function(dtime)
    for _, player in pairs(minetest.get_connected_players()) do
        local lantern_item = player:get_inventory():get_stack("lantern", 1)
        if lantern_item:is_empty() then return end
        lantern_item = lantern_item:get_name()
        lantern_def = minetest.registered_nodes[lantern_item]
        if not lantern_def or lantern_def.light_source == 0 then
            return
        end
        local pos = player:get_pos()
        pos = vector.round(pos)
        local node = minetest.get_node(pos).name
        if node == "air" or minetest.get_item_group(node, "glowing_air") == 1 then
            minetest.set_node(pos, {name = "lanterns:light_" .. lantern_def.light_source})
            get_and_set_timer(pos, 0.15, true)
        end
    end
end)
