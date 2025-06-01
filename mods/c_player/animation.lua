--[[
due to weirdenss when exporting model the convention is that they are
at 1 frame per second and the actual speed is set in the animation_speed property
	specifically, other frame/second settings in blender result in the animation
	range not being respected (somethimes?)

set_animation(frame_range, frame_speed, frame_blend, frame_loop)

player = 'p_data'{
	current_animation = "",
	idle_timeout = 0,
}

]]

c_player.animation = {}

-- TODO: expand this to check under the four corners of the collision box instead
local function is_on_ground(player)
	local pos = player:get_pos()
	pos.y = pos.y - 0.1
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	return def.walkable
end
c_player.is_on_ground = is_on_ground
local function is_climbing(player)
	local pos = player:get_pos()
	pos.y = pos.y
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	return def.climable
end
c_player.is_climbing = is_climbing
local function is_moving(controls)
	return (math.abs(controls.movement_x) + math.abs(controls.movement_y)) > 0.1
end


local animations = {
	["standing"] = {range = {x=1, y=24}, speed = 24, blend = 1, loop = true},
	["sneaking"] = {range = {x=26, y=49}, speed = 24 * 2, blend = 1, loop = true},
	["walking"] = {range = {x=51, y=74}, speed = 24 * 2, blend = 1, loop = true},
	["rising"] = {range = {x=101, y=101}, speed = 0, blend = 1, loop = true},
	["falling"] = {range = {x=102, y=102}, speed = 0, blend = 1, loop = true},
	-- idle = {
	-- 	{range = {x=0, y=20}, speed = 10, blend = 0, loop = true},
	-- 	{range = {x=0, y=20}, speed = 10, blend = 0, loop = true},
	-- }
}

local players = {}

local function start_handling_animations(player)
	players[player] = {
		idle_timer = 0,
		animation_override = nil,
		override_timeout = nil,
	}
end
c_player.animation.start_handling_animations = start_handling_animations
local function stop_handling_animations(player)
	players[player] = nil
end
c_player.animation.stop_handling_animations = stop_handling_animations

local function set_animation_override(player, animation_name, timeout)
	local p_data = players[player]
	p_data.animation_override = animation_name
	p_data.override_timeout = timeout
end
c_player.animation.set_animation_override = set_animation_override
local function end_animation_override(player)
	local p_data = players[player]
	p_data.animation_override = nil
	p_data.override_timeout = nil
end
c_player.animation.end_animation_override = end_animation_override

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
		-- TODO: insert a timeout for animations that aren't looped
	end

	if speed_multiplier then
		player:set_animation_frame_speed(p_data.base_speed * speed_multiplier)
	end
end
c_player.animation.set_animation = set_animation

local function select_animation(player)
	local p_data = players[player]

	if p_data.animation_override then
		return p_data.animation_override
	end

	local controls = player:get_player_control()
	local velocity = player:get_velocity()
	local grounded = is_on_ground(player) and velocity.y == 0
	local climbing = is_climbing(player) and not grounded
	local moving = is_moving(controls)

	local animation, speed = "standing", nil

	if grounded then
		if controls.sneak then
			animation = "sneaking"
		elseif moving then
			animation = "walking"
		end
	elseif not climbing then
		if velocity.y >= 0 then
			animation = "rising"
		else
			animation = "falling"
		end
	end

	if animation == "sneaking" or animation == "walking" then
		local horizontal_velocity = vector.new(velocity.x, 0, velocity.z)
		speed = horizontal_velocity:length() / 4
	elseif animation == "climbing" then
		speed = velocity.y / 4
	end
	-- print("FOOOOOOOOOOOOOOOOOOOOOO:  " .. animation)
	return animation, speed
end
c_player.animation.select_animation = select_animation


local function control_player_animations(player)
	local animation_name, speed_multiplier = select_animation(player)
	set_animation(player, animation_name, speed_multiplier)
end
local function update_player_data(player, dtime)
	local p_data = players[player]
	p_data.idle_timer = p_data.idle_timer + dtime
	if p_data.override_timeout then
		p_data.override_timeout = p_data.override_timeout - dtime
		if p_data.override_timeout <= 0 then
			end_animation_override(player)
		end
	end
end
core.register_globalstep(function(dtime)
	for player, p_data in pairs(players) do
		control_player_animations(player)
		update_player_data(player, dtime)
	end
end)


core.register_on_joinplayer(start_handling_animations)
core.register_on_leaveplayer(stop_handling_animations)
