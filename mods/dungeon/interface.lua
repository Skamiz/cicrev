
if true then return end
local fs = {
	"formspec_version[6]",
	"size[26,13]",
	"padding[0,0]",
	"bgcolor[#0000;neither;#000f]",
	"container[11.5,10]",
	"image_button[0,0;1,1;dungeon_arrow_turn.png^[transformFX;turn_left;]",
	"image_button[2,0;1,1;dungeon_arrow_turn.png;turn_right;]",
	"image_button[1,0;1,1;dungeon_arrow_forward.png;move_forward;]",
	"image_button[0,1;1,1;dungeon_arrow_forward.png^[transformR90;move_left;]",
	"image_button[1,1;1,1;dungeon_arrow_forward.png^[transformR180;move_back;]",
	"image_button[2,1;1,1;dungeon_arrow_forward.png^[transformR270;move_right;]",
	"",
	"image_button[5,0;1,1;dungeon_arrow_forward.png;center;]",
	"container_end[]",
	"",
}

minetest.register_on_joinplayer(function(player)
	player:set_inventory_formspec(table.concat(fs))
end)

local function print_table(po)
	for k, v in pairs(po) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then return end
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
		pos = pos + dir * 3
		player:set_pos(pos)
	end
	if fields.move_back then
		pos = pos + dir * -3
		player:set_pos(pos)
	end
	if fields.move_right then
		dir.x, dir.z = dir.z, -dir.x
		pos = pos + dir * 3
		player:set_pos(pos)
	end
	if fields.move_left then
		dir.x, dir.z = dir.z, -dir.x
		pos = pos + dir * -3
		player:set_pos(pos)
	end
	if fields.turn_right then
		local yaw = player:get_look_horizontal()
		player:set_look_horizontal(yaw + math.pi * 1.5)
	end
	if fields.turn_left then
		local yaw = player:get_look_horizontal()
		player:set_look_horizontal(yaw + math.pi * 0.5)
	end

	print_table(fields)

	return true
end)
