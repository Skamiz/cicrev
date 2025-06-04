--[[
TODO: on sleep set player in sleep state

]]


--[[ just debug stuff
c_sleep.register_on_sleep_start(function(player)
	core.chat_send_player(player:get_player_name(), "You started sleeping.")
end)
c_sleep.register_on_sleep_end(function(player)
	core.chat_send_player(player:get_player_name(), "You stopped sleeping.")
end)
--]]

minetest.register_node("cicrev:pillow", {
	description = "Pillow\nCan be rested on.",
	tiles = {"cicrev_pillow_top.png", "cicrev_pillow_top.png", "cicrev_pillow_side.png"},
	drawtype = "nodebox",
	node_box = {type = "fixed",
		fixed = {-8/16, -8/16, -8/16, 8/16, 0/16, 8/16}
	},
	groups = {soft = 3, hand = 2},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if c_sleep.start_sleep(clicker) then
			clicker:set_pos(pos)
		end
	end,
})

c_key_events.register_callback(c_sleep.end_sleep, "jump", "pressed")

c_sleep.register_on_sleep_start(function(player)
	-- TODO: make this a player effect
	player:set_physics_override({speed =  0,})
	core.after(1, function() player:set_velocity(vector.zero()) end)
end)
c_sleep.register_on_sleep_end(function(player)
	player:set_physics_override({speed =  1,})
end)


c_sleep.integration.prevent_sleep_while_moving()
c_sleep.integration.stop_sleeping_on_damage()
c_sleep.integration.speedup_time(20, 0.5)
c_sleep.integration.force_3rd_person_camera()
c_sleep.integration.show_sleeping_players()
c_sleep.integration.sleepers_snore(0.5)
