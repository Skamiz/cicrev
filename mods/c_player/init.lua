local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
-- dofile(modpath .. "/foo.lua")

local p = 1 / 16
sfinv.override_page("sfinv:crafting", {
	get = function(self, player, context)
		local fs = {
			"formspec_version[6]",
			"size[13.25,12]",
			sfinv and sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx) or "",
			"container[0.5,0.5]",
			"box[" .. -2*p .. "," .. 6.25 - 2*p .. ";" .. 12.25 + 4*p .. "," .. 4.75 + 4*p .. ";#FFF0]",
			"list[current_player;main;0,6.25;10,4;]",
			"container[0,6.25]",
			auto_storage.get_locked_highlight(player),
			"container_end[]",
			"list[current_player;lantern;0,5;1,1]",
			"list[context;hand;1.25,5;1,1]", -- TODO: move this to creative mod
			"box[11.25,5;1,1;#0000]",
			"image_button[11.25,5;1,1;store_to_nearby.png;store_to_nearby;]",
			"tooltip[store_to_nearby;Store to nearby]",
			"container_end[]",
		}
		fs = table.concat(fs)
		if minetest.global_exists("cfs") then
			fs = cfs.style_formspec(fs, player)
		end
		return fs
	end
})


local hotbar_length = 10
minetest.register_on_joinplayer(function(player, last_login)
	local inv = player:get_inventory()
	inv:set_size("main", 40) -- only required on first join
	player:set_properties({
		zoom_fov = 15.0,
	})
	player:hud_set_hotbar_itemcount(hotbar_length)
	player:hud_set_hotbar_image(cicrev.get_hotbar_image("cicrev_hotbar.png", hotbar_length))
	player:hud_set_hotbar_selected_image("cicrev_hotbar_selected.png")
end)


-- minetest.override_item(":", {
--
-- })
