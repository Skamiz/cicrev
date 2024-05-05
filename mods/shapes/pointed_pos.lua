-- camera position
local function get_eye_pos(player)
	local eye_pos = player:get_pos()
	local eye_height = player:get_properties().eye_height
	local eye_offset = player:get_eye_offset() / 10

	eye_pos.y = eye_pos.y + eye_height
	eye_pos = eye_pos + eye_offset

	return eye_pos
end

-- player reach
local function get_player_reach(player)
	-- wielded item
	local wielded_item = player:get_wielded_item():get_name()
	local wielded_def = minetest.registered_items[wielded_item]
	if wielded_def.range then
		return wielded_def.range
	end

	-- hand list item
	local inv = player:get_inventory()
	local hand_name = inv:get_stack("hand", 1):get_name()
	local hand_def = minetest.registered_items[hand_name]
	if hand_def.range then
		return hand_def.range
	end

	-- engine builtin
	return 4
end

-- absolute end of reach position
function shapes.get_looked_pos(player, distance)
	distance = distance or get_player_reach(player)
	local eye_pos = get_eye_pos(player)
	local look_dir = player:get_look_dir()
	local pos = eye_pos + (look_dir * distance)

	return pos
end


function shapes.pointed_pos(player, distance, mode)
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
	end
	mode = mode or "distance"
	distance = distance or get_player_reach(player)

	local eye_pos = get_eye_pos(player)
	local look_dir = player:get_look_dir()
	local target_pos = eye_pos + (look_dir * distance)

	if mode == "distance" then
		return target_pos
	end

	local ray = minetest.raycast(eye_pos, target_pos, false, false)
	local pt = ray:next()

	-- if there simply isn't a node in the pointed direction
	if not pt then return target_pos end

		if mode == "above" then
			return pt.above
		elseif mode == "under" then
			return pt.under
		elseif mode == "exact" then
			return pt.intersection_point
		end

	-- distance mode is also used as fallback
	return target_pos
end
