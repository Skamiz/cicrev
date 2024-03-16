--[[
setting reach to zero to disable node highlighting

]]



-- if true then return end
local INPUT_TIMEOUT = 0.1
local player_timeouts = {}

local function move_to(player, pos)
	local traversible = dungeon.move.is_tile_traversible((pos + vector.new(0, 1.5, 0)):round())
	if not traversible then return end
	player:set_pos(pos)
	dungeon.move.reorient(player)
end

local action = {
	interact = function(player)
		local head_pos = (player:get_pos() + vector.new (0, 1.5, 0)):round()
		local dir = player:get_look_dir():round()
		for i = 1, dungeon.TILE_SIZE do
			local pos = head_pos + dir * i
			local node = minetest.get_node(pos)
			local def = minetest.registered_items[node.name]
			if def._on_interact then
				-- print("interacted with: " .. def.description)
				def._on_interact(pos, node, player)
				break
			end
		end
	end,
	move_forward = function(player)
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		pos = pos + dir * 3
		move_to(player, pos)
	end,
	-- move_forward = dungeon.move.forward,
	move_back = function(player)
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		pos = pos + dir * -3
		move_to(player, pos)
	end,
	move_right = function(player)
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		dir.x, dir.z = dir.z, -dir.x
		pos = pos + dir * 3
		move_to(player, pos)
	end,
	move_left = function(player)
		local pos = player:get_pos()
		local dir = player:get_look_dir()
		dir.x, dir.z = dir.z, -dir.x
		pos = pos + dir * -3
		move_to(player, pos)
	end,
	turn_right = function(player)
		local yaw = player:get_look_horizontal()
		player:set_look_horizontal(yaw + math.pi * 1.5)
	end,
	turn_left = function(player)
		local yaw = player:get_look_horizontal()
		player:set_look_horizontal(yaw + math.pi * 0.5)
	end,
}

local letters = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l",
 		"m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"}
local i_letters = table.key_value_swap(letters)
local input_map = {
	q = action.turn_left,
	w = action.move_forward,
	e = action.turn_right,
	a = action.move_left,
	s = action.move_back,
	d = action.move_right,
	p = action.interact,
	r = dungeon.move.reorient,
}

local get

local n = 0
local function get_dd_formspec(player, disable_inputs)
	local width, height = 30, 15
	n = n + 1
	local fs = {
		"formspec_version[6]",
		"size[" .. width .. "," .. height .. ",false]",
		"padding[0,0]",
		-- label with changing number to force formspec update
		"label[8,1;" .. n .. "]",
		"bgcolor[#0000;neither;#000f]",

		"container[" .. width/2 .. "," .. height .. "]",
		"image_button[-1.5,-2;1,1;dungeon_arrow_turn.png^[transformFX;turn_left;]",
		"image_button[-0.5,-2;1,1;dungeon_arrow_forward.png;move_forward;]",
		"image_button[0.5,-2;1,1;dungeon_arrow_turn.png;turn_right;]",
		"image_button[-1.5,-1;1,1;dungeon_arrow_forward.png^[transformR90;move_left;]",
		"image_button[-0.5,-1;1,1;dungeon_arrow_forward.png^[transformR180;move_back;]",
		"image_button[0.5,-1;1,1;dungeon_arrow_forward.png^[transformR270;move_right;]",
		"",
		"image_button[5,-2;1,1;dungeon_arrow_forward.png;center;]",
		"container_end[]",
		-- "image_button[0,0;1,1;dungeon_arrow_forward.png;center;]",
		-- "image_button[29,14;1,1;dungeon_arrow_forward.png;center;]",
		"",
		"set_focus[key_input;true]",
	}
	if not disable_inputs then
		fs[#fs + 1] = "textlist[5,0;2,3;key_input;" .. table.concat(letters, ",") .. ";16;true]"
	end
	local fs = table.concat(fs)
	return fs
end

local function show_player_dd_formspec(player, disable_inputs)
	local fs = get_dd_formspec(player, disable_inputs)
	minetest.show_formspec(player:get_player_name(), "dungeon_main", fs)
end



minetest.register_on_joinplayer(function(player)
	-- player:set_inventory_formspec(get_dd_formspec(player))
end)

local function print_table(po)
	for k, v in pairs(po) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	-- local wi = minetest.get_player_window_information(player:get_player_name())
	-- print(dump(wi))
	if formname ~= "dungeon_main" then return end
	local player_name = player:get_player_name()
	local pos = player:get_pos()
	local dir = player:get_look_dir()

	if fields.center then
		pos.y = pos.y + 0.49
		pos = pos:round()
		pos.y = pos.y - 0.49
		player:set_pos(pos:round())
		player:set_look_horizontal(0)
		player:set_look_vertical(0)
	end

	if fields.move_forward then
		action.move_forward(player)
	end
	if fields.move_back then
		action.move_back(player)
	end
	if fields.move_right then
		action.move_right(player)
	end
	if fields.move_left then
		action.move_left(player)
	end
	if fields.turn_right then
		action.turn_right(player)
	end
	if fields.turn_left then
		action.turn_left(player)
	end

	if fields.key_input then
		if player_timeouts[player_name] then return end
		local event = minetest.explode_textlist_event(fields.key_input)
		local input = letters[event.index]
		local action = input_map[input]
		if action then
			action(player)
			player_timeouts[player_name] = INPUT_TIMEOUT
		end
		show_player_dd_formspec(player, true)
		minetest.after(0.05, function()
			-- TODO: check if showing a textlist with a different name also resets input cooldown
			player_timeouts[player_name] = nil
			show_player_dd_formspec(player)
		end)
	else
		show_player_dd_formspec(player)
	end


	return true
end)

-- minetest.register_globalstep(function(dtime)
-- 	for player_name, timout in pairs(player_timeouts) do
-- 		player_timeouts[player_name] = timout - dtime
-- 		if player_timeouts[player_name] < 0 then
-- 			player_timeouts[player_name] = nil
-- 			local player = minetest.get_player_by_name(player_name)
-- 			show_player_dd_formspec(player)
-- 		end
-- 	end
-- end)

minetest.register_chatcommand("di", {
	params = "",
	description = "Show dungeoneering interface.",
	privs = {},
	func = function(name, param)
		show_player_dd_formspec(minetest.get_player_by_name(name))
	end,
})
