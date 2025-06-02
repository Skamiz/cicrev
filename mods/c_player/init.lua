local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

c_player = {}
-- desired size in pixels / current size in nodes
local scale = (30 / 32) / (1.6 / 2)
c_player.default_properties = {
	visual = "mesh",
	mesh = "player_joints.glb",
	textures = {"skin_template_joints.png"},
	visual_size = {x = scale, y = scale, z = scale},

	eye_height = 1.75,
	collisionbox = {-0.3, 0, -0.3, 0.3, 30/16, 0.3},
	selectionbox = {-0.3, 0, -0.3, 0.3, 30/16, 0.3},
}
minetest.register_on_joinplayer(function(player, last_login)
	player:set_properties(table.copy(c_player.default_properties))
end)

dofile(modpath .. "/sneaking.lua")
-- dofile(modpath .. "/model.lua")
dofile(modpath .. "/animation.lua")
-- dofile(modpath .. "/foo.lua")

dofile(modpath .. "/regeneration.lua")

local p = 1 / 16
sfinv.override_page("sfinv:crafting", {
	get = function(self, player, context)
		local fs = {
			"formspec_version[6]",
			"size[13.25,12]",
			"padding[0,0]",

			sfinv and sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx) or "",
			"container[0.5,0.5]",
			"box[" .. -2*p .. "," .. 6.25 - 2*p .. ";" .. 12.25 + 4*p .. "," .. 4.75 + 4*p .. ";#FFF0]",
			"list[current_player;main;0,6.25;10,4;]",
			-- "list[current_player;craft;3,0;3,3;]",
    		-- "list[current_player;craftpreview;7,1;1,1;]",
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
		eye_height = 1.75,
		-- zoom_fov = 15.0,
		-- visual = "mesh",
		-- mesh = "player_joints.b3d",
		-- mesh = "character.b3d",
		-- textures = {"skin_template_joints.png"},
		-- visual_size = {x = 1/2, y = 1/2, z = 1/2},
		-- visual_size = {x = 2, y = 2, z = 2},
		-- visual_size = {x = 1, y = 1, z = 1},
	})
	player:hud_set_hotbar_itemcount(hotbar_length)
	player:hud_set_hotbar_image(cicrev.get_hotbar_image("cicrev_hotbar.png", hotbar_length))
	player:hud_set_hotbar_selected_image("cicrev_hotbar_selected.png")

end)

local r = 0
minetest.register_globalstep(function(dtime)
	r = r + 1
	-- minetest.chat_send_all(r)
	for _, player in pairs(minetest.get_connected_players()) do
		-- player:set_bone_override("head", {
		-- 	rotation = {
		-- 		vec = vector.new(0, math.rad(r), 0),
		-- 		interpolation = 0,
		-- 		absolute = true,
		-- 	}
		-- })
		-- player:set_animation({x=1, y=20}, 10, 0, true)
	end
end)


-- minetest.override_item(":", {
--
-- })
sfinv.register_page("c_creative", {
title = "Creative",
get = function(self, player, context)
	local fs = {
		"formspec_version[6]",
		"size[13.25,12]",
		"padding[0,0]",

		sfinv and sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx) or "",
		"container[0.5,0.5]",
			"box[" .. -1*p .. "," .. 0 - 1*p .. ";" .. 12.25 + 2*p .. "," .. 0.75 + 2*p .. ";#FFF0]",
			"box[" .. -2*p .. "," .. 6.25 - 2*p .. ";" .. 12.25 + 4*p .. "," .. 4.75 + 4*p .. ";#FFF0]",
			c_creative.get_creative_inv_fs(player, 10, 4),
			"list[current_player;main;0,6.25;10,4;]",
			"listring[]",
		"container_end[]",
	}
	fs = table.concat(fs)
	if minetest.global_exists("cfs") then
		fs = cfs.style_formspec(fs, player)
	end
	return fs
end,
})
c_creative.register_callback("", sfinv.set_player_inventory_formspec)
