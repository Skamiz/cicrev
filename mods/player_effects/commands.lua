local modname = minetest.get_current_modname()

local function print_po(po)
	for k, v in pairs(po) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : '" .. tostring(v) .. "'")
	end
end

local function show_pysiscs_formspec(name)
	local player = minetest.get_player_by_name(name)
	local po = player:get_physics_override()
	local fs = "formspec_version[4]" ..
	"size[10.75,8.5]"..
	"container[0.5,0.5]"

	local n = 0
	for k, v in pairs(po) do
		fs = fs .. "label[0," .. n + 0.5 .. ";" .. k .. "]"
		if type(v) == "boolean" then
			fs = fs .. "checkbox[5," .. n + 0.5 .. ";" .. k .. ";;" .. tostring(v) .. "]"
		elseif type(v) == "number" then
			fs = fs .. "field[5," .. n + 0.25 .. ";2,0.5;" .. k .. ";;" .. v .. "]"
		end
		n = n + 1
	end

	fs = fs .. "container_end[]"
	minetest.show_formspec(name, modname .. ":physics_override",fs)
end

minetest.register_chatcommand("phys", {
	params = "phys",
	description = "Allows to change own physics override.",
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		local po = player:get_physics_override()
		-- print_po(po)
		show_pysiscs_formspec(name)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if not formname == modname .. ":physics_override" then return false end
	-- local player = minetest.get_player_by_name(player:)
	local po = player:get_physics_override()
	po.speed = fields.speed or po.speed
	po.jump = fields.jump or po.jump
	po.gravity = fields.gravity or po.gravity
	if fields.sneak ~= nil then po.sneak = (fields.sneak == "true") end
	if fields.sneak_glitch ~= nil then po.sneak_glitch = (fields.sneak_glitch == "true") end
	if fields.new_move ~= nil then po.new_move = (fields.new_move == "true") end
	-- print_po(po)
	player:set_physics_override(po)
end)


-- command for manualy setting effects
-- TODO: this will crash the game with bad input
minetest.register_chatcommand("effect", {
	params = "[add|remove] effect_name effect_source [set|add|multiply] strenght priority timeout",
	description = "Add and remove effects by command.",
	func = function(name, params)
		local player = minetest.get_player_by_name(name)
		local params = params:split(' ')
		print_po(params)

		if params[1] == "add" then
			player_effects.add_effect(player, {
				effect_name = params[2],
				source = params[3],
				influence = player_effects.influence_funcitons[params[4]](params[5]),
				priority = tonumber(params[6]),
				timeout = tonumber(params[7])
			})
		elseif params[1] == "remove" then
			player_effects.remove_effect(player, params[2], params[3])
		else
			minetest.chat_send_player(name, "Instructions unclear, use 'add' of 'remove'.")
		end

	end
})
