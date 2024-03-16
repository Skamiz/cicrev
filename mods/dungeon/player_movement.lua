
minetest.register_on_joinplayer(function(player)
	player:set_properties({
		eye_height = 1.5,
		stepheight = 1.1,
	})
	-- player:set_physics_override({
	-- 	speed = 0,
	-- })
	-- player:set_eye_offset(vector.new(0, 0, -14))
end)


dungeon.move = {}


local function is_tile_traversible(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_items[node.name]
	local walkable_rating = def.groups and def.groups.walkable
	if walkable_rating then
		if walkable_rating == 1 then
			return true
		elseif walkable_rating == 2 then
			return false
		end
	end
	return not def.walkable
end
dungeon.move.is_tile_traversible = is_tile_traversible



-- players in this table are currently moving and ignore new inputs
local players = {}
local move_speed = 0.5 -- in seconds / tile moved | 90 deg turned, limmited by input speed

local function reset_orientation(player)
	-- set position to center of node
	local pos = player:get_pos()
	pos.x = math.round(pos.x)
	pos.z = math.round(pos.z)
	player:set_pos(pos)

	-- set look direction to be orthogonal
	local dir = player:get_look_horizontal()
	dir = dir / math.pi * 2
	dir = math.round(dir)
	dir = dir * math.pi * 0.5
	player:set_look_horizontal(dir)

	player:set_look_vertical(0)
end
dungeon.move.reorient = reset_orientation

local function move_towards(player, destination_pos)
	reset_orientation(player)
	local traversible = is_tile_traversible((destination_pos + vector.new(0, 1.5, 0)):round())
	if not traversible then print("wall") return end
	local player_name = player:get_player_name()
	if players[player_name] then return end

	local current_pos = player:get_pos()
	local direction = (destination_pos - current_pos) / move_speed
	player:set_physics_override({speed = 0})
	player:add_velocity(direction)

	players[player_name] = {
		motion = "move",
		player = player,
		start_pos = current_pos,
		end_pos = destination_pos,
		direction = direction,
		start_time = minetest.get_us_time(),
	}
end

local function move_forward(player)
	local current_pos = player:get_pos()
	local dir = player:get_look_dir()
	local destination = current_pos + dir * 3
	move_towards(player, destination)
end
dungeon.move.forward = move_forward

minetest.register_globalstep(function(dtime)
	for player_name, move_data in pairs(players) do
		local player = move_data.player
		local current_pos = player:get_pos()
		local distance = move_data.end_pos - current_pos
		local projected_move = move_data.direction * dtime

		if (move_data.end_pos - move_data.start_pos):length() < ((current_pos + projected_move) - move_data.start_pos):length()
		-- if distance:length() < (current_pos + projected_move):length()
		-- or (minetest.get_us_time() - move_data.start_time)/1000000 > move_speed
		then
			player:add_velocity(player:get_velocity() * -1)
			-- player:set_physics_override({speed = 10})
			reset_orientation(player)
			players[player_name] = nil
		end
	end
end)
