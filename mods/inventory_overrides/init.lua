local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
-- dofile(modpath .. "/foo.lua")

sfinv.override_page("sfinv:crafting", {
	get = function(self, player, context)
		local s = ""
		.. "formspec_version[6]"
		.. "size[10.25, 10.25]"
		.. sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx)
		.. "listcolors[#777777;#929292]"
		.. "list[current_player;main;0.25,5.25;8,4;]"
		.. "container[2.125,0.25]"
		.. "list[current_player;craft;0,0;3,3;]"
		-- .. "image[3.75,1.25;1,1;sfinv_crafting_arrow.png]"
		.. "list[current_player;craftpreview;5,1.25;1,1;]"
		.. "container_end[]"
		.. "listring[current_player;main]"
		.. "listring[current_player;craft]"
		.. "bgcolor[;neither;]"
		.. "background[0,0;10.25,10.25;sfinv_craft_background.png;false]"

		return s
	end
})
