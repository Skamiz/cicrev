minetest.register_on_joinplayer(
    function(player)
        local inv_ref = player:get_inventory()
        inv_ref:set_size("hand", 1)
    end
)

-- sfinv.register_page("hand_slot:hand", {
--     title = "hand slot",
--     get = function(self, player, context)
--         return sfinv.make_formspec(player, context,
--                 "list[context;hand;4.5,1;1,1;]", true)
--     end
-- })

local orig_get = sfinv.pages["sfinv:crafting"].get
sfinv.override_page("sfinv:crafting", {
    get = function(self, player, context)
        local fs = orig_get(self, player, context)
        return fs .. "list[context;hand;0,2;1,1]"
    end
})

minetest.register_tool("hand_slot:admin_tool", {
    description = "Admins Hand",
    inventory_image = "hand_slot_hand.png",

    tool_capabilities = {
        full_punch_interval = 1,
        -- max_drop_level = 1,
        groupcaps = {
            hand = {times = { [1]=0.3, [2]=0.3, [3]=0.3 }},
            cracky = {times = { [1]=0.3 }},
            choppy = {times = { [1]=0.3 }},
        },
    },
})
