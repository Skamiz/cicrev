minetest.register_on_joinplayer(
    function(player)
        local inv_ref = player:get_inventory()
        inv_ref:set_size("hand", 1)
    end
)

local orig_get = sfinv.pages["sfinv:crafting"].get
sfinv.override_page("sfinv:crafting", {
    get = function(self, player, context)
        local fs = orig_get(self, player, context)
        return fs .. "list[context;hand;0.25,2.75;1,1]"
    end
})
