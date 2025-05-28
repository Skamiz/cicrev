--[[
set_animation(frame_range, frame_speed, frame_blend, frame_loop)

player = 'p_data'{
	current_animation = "",
	last_position = pos,
	etc...
}

]]

local animations = {
	["standing"] = {range = {x=0, y=20}, speed = 1, blend = 0, loop = true},
	["walking"] = {range = {x=0, y=20}, speed = 10, blend = 1, loop = true},
	idle = {
		{range = {x=0, y=20}, speed = 10, blend = 0, loop = true},
		{range = {x=0, y=20}, speed = 10, blend = 0, loop = true},
	}
}

local players = {}

local function start_handling_animations(player)
	players[player] = {}
end
local function stop_handling_animations(player)
	players[player] = nil
end

local function set_animation(player, animation_name, speed_multiplier)
	local p_data = players[player]
	if p_data.current_animation ~= animation_name then
		local animation_data = animations[animation_name]
		-- if multiple animations of same name, select a random one
		if animation_data[1] then
			animation_data = animation_data[math.random(1, #animation_data)]
		end

		player:set_animation(animation_data.range, animation_data.speed, animation_data.blend, animation_data.loop)
		p_data.current_animation = animation_name
		p_data.base_speed = animation_data.speed
	end

	if speed_multiplier then
		player:set_animation_frame_speed(p_data.base_speed * speed_multiplier)
	end
end

local function select_animation(player)
	local p_data = players[player]
	local controls = player:get_player_control()
	-- print(controls.movement_y)
	if controls.movement_y > 0.5 then
		return "walking"
	end
	return "standing"
end

local function control_player_animations(player)
	local animation_name, speed_multiplier = select_animation(player)
	set_animation(player, animation_name, speed_multiplier)
end
local function update_player_data(player, dtime)
	local p_data = players[player]
	p_data.last_pos = player:get_pos()
end
core.register_globalstep(function(dtime)
	for player, p_data in pairs(players) do
		control_player_animations(player)
		-- update_player_data(player, dtime)
	end
end)


core.register_on_joinplayer(start_handling_animations)
core.register_on_leaveplayer(stop_handling_animations)
