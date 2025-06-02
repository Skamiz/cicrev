c_sleep.integration = {}
local integration = c_sleep.integration


-- limit time period in which it is possible to start sleeping
integration.limit_sleep_time = function(start_time, end_time)
	local old_can_sleep = c_sleep.can_sleep
	c_sleep.can_sleep = function(player)
		local time_of_day = core.get_timeofday()
		print(time_of_day)
		if start_time > end_time then
			if time_of_day > end_time and time_of_day < start_time then
				return false, "Now isn't the time to sleep."
			end
		else
			if time_of_day > end_time or time_of_day < start_time then
				return false, "Now isn't the time to sleep."
			end
		end

		return old_can_sleep(player)
	end
end
-- prevent sleep while moving
integration.prevent_sleep_while_moving = function()
	local old_can_sleep = c_sleep.can_sleep
	c_sleep.can_sleep = function(player)
		local velocity = player:get_velocity()
		if velocity:length() > 0.01 then
			return false, "Can't sleep while moving."
		end
		return old_can_sleep(player)
	end
end
-- if enough players are sleeping, skip to specified time
integration.skip_to_morning = function(time, player_fraction)
	c_sleep.register_on_count_changed(function(n_sleeping, n_total)
		if (n_sleeping / n_total) > player_fraction then
			core.set_timeofday(time)
			c_sleep.wake_everyone_up()
		end
	end)
end
-- take players interact priv while they are asleep
-- WARNING: this requires a method of waking up that doesn't rely on interact
integration.limit_interaction = function()
	local sleepers_with_interact = {}
	c_sleep.register_on_sleep_start(function(player)
		local p_name = player:get_player_name()
		if core.check_player_privs(player, "interact") then
			sleepers_with_interact[p_name] = true
		end
		core.change_player_privs(p_name, {interact = false})
	end)
	c_sleep.register_on_sleep_end(function(player)
		local p_name = player:get_player_name()
		if sleepers_with_interact[p_name] then
			core.change_player_privs(p_name, {interact = true})
		end
	end)
end
-- while players asleep, speed up day/night cycle
integration.speedup_time = function(multiplier, player_fraction)
	local time_speed = tonumber(core.settings:get("time_speed"))
	c_sleep.register_on_count_changed(function(n_sleeping, n_total)
		if (n_sleeping / n_total) > player_fraction then
			core.settings:set("time_speed", time_speed * multiplier)
		else
			core.settings:set("time_speed", time_speed)
		end
	end)
end
-- display a hud showing fraction of sleeping players to sleeping players
integration.show_sleeping_players = function()
	local sleepers = {}

	local function show_hud(player)
		local hud_id = player:hud_add({
			type = "text",
			number = 0xffffff,
			position = {x = 0.1, y = 0.8},
			text = "The sleeper is coming!",
		})
		sleepers[player] = hud_id
	end
	local function update_hud(n_sleeping, n_total)
		local messege = "Sleeping: %s of %s players."
		for player, hud_id in pairs(sleepers) do
			player:hud_change(hud_id, "text", messege:format(n_sleeping, n_total))
		end
	end
	local function remove_hud(player)
		player:hud_remove(sleepers[player])
		sleepers[player] = nil
	end

	c_sleep.register_on_sleep_start(function(player)
		show_hud(player)
		update_hud()
	end)
	c_sleep.register_on_sleep_end(function(player)
		remove_hud(player)
		update_hud()
	end)
	c_sleep.register_on_count_changed(function(n_sleeping, n_total)
		update_hud(n_sleeping, n_total)
	end)
end
-- make chat messeges of sleeping players into various snoring noises
-- TODO: implement snoring variety
integration.sleepers_snore = function(snore_percenatage)
	local msg = "<%s> %s"
	core.register_on_chat_message(function(name, message)
		if c_sleep.sleeping_players[name] then
			minetest.chat_send_all(msg:format(name, "zZzZz"))
			return true
		end
	end)
end
-- set camera of sleeping players to 3d person
integration.force_3rd_person_camera = function()
	c_sleep.register_on_sleep_start(function(player)
		local camera = player:get_camera()
		player:set_camera({mode = "third"})
		minetest.after(0.1, function() player:set_camera(camera) end)
	end)
end
-- wake sleeping player up if they take damage
integration.stop_sleeping_on_damage = function()
	core.register_on_player_hpchange(function(player, hp_change, reason)
		if hp_change < 0 then
			c_sleep.end_sleep(player)
		end
	end, false)
end
