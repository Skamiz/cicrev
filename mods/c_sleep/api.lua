local function make_registration()
	local registered = {}
	local register = function(f)
		table.insert(registered, f)

	end
	return registered, register
end

local function count_entries(t)
	local n = 0
	for _, _ in pairs(t) do
		n = n + 1
	end
	return n
end

c_sleep.sleeping_players = {}

c_sleep.registered_on_sleep_start, c_sleep.register_on_sleep_start = make_registration()
c_sleep.registered_on_sleep_end, c_sleep.register_on_sleep_end = make_registration()
c_sleep.registered_on_count_changed, c_sleep.register_on_count_changed = make_registration()

local function call_on_count_changed_callbacks()
	local n_sleeping = count_entries(c_sleep.sleeping_players)
	local n_total = count_entries(core.get_connected_players())
	for i, func in ipairs(c_sleep.registered_on_count_changed) do
		func(n_sleeping, n_total)
	end
end

c_sleep.start_sleep = function(player)
	if c_sleep.is_sleeping(player) then return end

	local can_sleep, reason = c_sleep.can_sleep(player)
	if not can_sleep then
		return can_sleep, reason
	end

	c_sleep.sleeping_players[player:get_player_name()] = true
	for i, func in ipairs(c_sleep.registered_on_sleep_start) do
		func(player)
	end

	call_on_count_changed_callbacks()

	return true
end

c_sleep.end_sleep = function(player)
	if not c_sleep.is_sleeping(player) then return end

	c_sleep.sleeping_players[player:get_player_name()] = nil
	for i, func in ipairs(c_sleep.registered_on_sleep_end) do
		func(player)
	end

	call_on_count_changed_callbacks()
end

-- override this function in similar fashion to 'core.is_creative_enabled(name)'
c_sleep.can_sleep = function(player)
	return true, nil
end

c_sleep.is_sleeping = function(player)
	return c_sleep.sleeping_players[player:get_player_name()]
end

-- convenience functions:
c_sleep.wake_everyone_up = function()
	for p_name, _ in pairs(c_sleep.sleeping_players) do
		local player = core.get_player_by_name(p_name)
		c_sleep.end_sleep(player)
	end
end
c_sleep.toggle_sleep = function(player)
	if not c_sleep.is_sleeping(player) then
		c_sleep.start_sleep(player)
	else
		c_sleep.end_sleep(player)
	end
end

-- update callbacks
core.register_on_joinplayer(call_on_count_changed_callbacks)
core.register_on_leaveplayer(call_on_count_changed_callbacks)

-- cleaning up
core.register_on_leaveplayer(c_sleep.end_sleep)
core.register_on_dieplayer(function(player, reason)
	c_sleep.sleeping_players[player:get_player_name()] = nil

	-- avoiding calling on_sleep_end callbacks,
	-- since they might restore player position after putting them in bed

	call_on_count_changed_callbacks()
end)

-- TODO: wake player up if they take damage
