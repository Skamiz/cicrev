--[[
Simple callback mechanism for detection of key events.

register_callback(callback, key*, "pressed" or "released"*)
'key_events.register_callback(callback, key, event)'
- callback = function(player, key, event),
- key = one of: "up", "down", "left", "right", "jump", "aux1", "sneak", "dig",
	"place", "zoom"
- event = "pressed" or "released"

'key' and 'event' are optional, if not set the callback will be called
for any key or event.

]]

c_key_events = {}
local key_events = c_key_events
local players = {}
key_events.players = players
key_events.registered_callbacks = {}

key_events.key_list = {
	["up"] = true,
	["down"] = true,
	["left"] = true,
	["right"] = true,
	["jump"] = true,
	["aux1"] = true,
	["sneak"] = true,
	["dig"] = true,
	["place"] = true,
	["zoom"] = true,
}

key_events.register_callback = function(callback, key, event)
	table.insert(key_events.registered_callbacks, {
		callback = callback,
		key = key,
		event = event,
	})
end

minetest.register_on_joinplayer(function(player)
	players[player] = player:get_player_control()
end)
minetest.register_on_leaveplayer(function(player)
	players[player] = nil
end)

local function call_callbacks(player, key, event)
	for _, callback_def in ipairs(key_events.registered_callbacks) do
		if ((not callback_def.key) or (callback_def.key == key)) and
				((not callback_def.event) or (callback_def.event == event)) then
			callback_def.callback(player, key, event)
		end
	end
end

local function update_player_inputs(player)
	local new_inputs = player:get_player_control()
	local old_inputs = players[player]

	for key, _ in pairs(key_events.key_list) do
		if (new_inputs[key] or old_inputs[key]) and not (new_inputs[key] and old_inputs[key]) then
			local pressed = new_inputs[key]
			call_callbacks(player, key, pressed and "pressed" or "released")

			if pressed then
				old_inputs[key] = true
			else
				old_inputs[key] = false
			end
		end
	end
end

minetest.register_globalstep(function(dtime)
	for player, _ in pairs(players) do
		update_player_inputs(player)
	end
end)
