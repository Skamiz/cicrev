local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)


--[[

terminlogy:
player_properties - mod name, name of main table
player_properties - effects currently applied to a player
property
	property_name
	default_value
	set - function that sets final property value
effect - a specific effect like the speed boost of a pair of boots
	description
	effect_icon
	effect_property?_type?
	priority


player_properties.register_property({
	name = "speed",
	description = "Speed",
	default_value = 1,
	set = function(player, value)
		player:set_physics_override({speed = value})
	end,
})

player_properties.add_effect(player, {
	source = "walkover_speed",
	affected_property = "speed",
	influence = function(speed) return speed * walkover_speed end,
	priority = 120,
})
player_properties.add_effect(player, {
	source = "rune",
	affected_property = "speed",
	-- text_influence = "function (s) return s + 0.3 end",
	text_influence = "function (s) return s + 0.5 end",
	duration = 30,
	priority = 80,
	persistent = true,
})
player_properties.add_effect(player, {
	source = "rune",
	affected_property = "speed",
	-- text_influence = "function (s) return s + 0.3 end",
	text_influence = "function (s) return s + 0.5 end",
	priority = 80,
	persistent = true,
	duration = 30,
	on_timeout = function(player) end,
})

equivalent to player_monoids
	first evaluate +- then */
can specify a timeout of the effect
callback on effect ending?
wheter the effect is persistent/gets saved/restored when the player leaves/joins

physics overrides
maxhealt override
speed overrides
	node group which specifies a speed multiplier in percentage
step_heigth
dizzines - involuntary turning/walking/jumping
whatever else

Scenarios:
- a ritual to get the player 5 min of increased speed
- permanently increase health
- a curse which damages health on timeout and restarts with a shorter timeout

Concepts:
- exchanging one stat for another eg. more speed, but no jumping


{
-- 	effect = "whatever addition/multiplication", -- from predefined effects
-- 	strength = 1,
-- 	source = "informational",
-- 	persistent = false/true,
-- 	time = n, -- in seconds
-- 	callback_on_timeout = funciton,
-- 	priority = n, -- order of effect evaluation
-- }

{
	e_type = [speed/gravity/max helath]
	source = "informational",
	text_influence = "[set|add|multiply] n" -- for when functions can't be persisted
	influence = function(value) return modified_value end
	priority = n, -- order of effect evaluation
	time = n, -- in seconds
	-- WARNING:functions can't be persisted across restarts
	persistent = false/true,
	callback_on_timeout = funciton,
}

local e = effect(player, effect)
e:stop() -- stops the effect


-- on initialization set all values to default_value, since it might differ from the default minetest value
--]]

player_properties = {}
local registered_properties = {}
local players = {}

--
player_properties.influence_functions = {
	set = function(es)
		return function() return es end
	end,
	add = function(es)
		return function(strenght) return strenght + es end
	end,
	multiply = function(es)
		return function(strenght) return strenght * es end
	end,
}

function player_properties.register_property(property)
	assert(not registered_properties[property.name], "Effect: '" .. property.name .. "' already exists")
	registered_properties[property.name] = property
end

dofile(modpath .. "/properties.lua")
dofile(modpath .. "/hud.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/walkover_speed.lua")

-- recalculate value of a property
local function update_property(player, property_name)
	local property = registered_properties[property_name]
	local player_name = player:get_player_name()
	local players_effects = players[player_name]

	local effect_strength = property.default_value
	for i, v in ipairs(players_effects[property_name]) do
		-- rename this to effect_infuluence
		effect_strength = v.influence(effect_strength)
	end
	property.set(player, effect_strength)

	player_properties.show_effect_hud(player, players_effects)
end

-- from table t find index of element for which source == effect.source
local function get_index(t, source)
	for i, effect in ipairs(t) do
		if effect.source == source then
			return i
		end
	end
end

function player_properties.remove_effect(player, effect_name, effect_source)
	local player_name = player:get_player_name()
	local player_effect_type = players[player_name][effect_name]

	local effect_index = get_index(player_effect_type, effect_source)
	if effect_index then
		table.remove(player_effect_type, effect_index)
		update_property(player, effect_name)
	else
		minetest.log("info", "Trying to remove nonexistent effect '" .. effect_name ..
				"' granted by '" .. effect_source .. "' on player '" .. player_name .. "'")
	end
end

local function sort_effects(e1, e2)
	return e1.priority < e2.priority
end

function player_properties.add_effect(player, effect)
	local player_name = player:get_player_name()
	local effect = table.copy(effect)
	local player_effect_type = players[player_name][effect.effect_name]

	local effect_index = get_index(player_effect_type, effect.source)
	if effect_index then
		table.remove(player_effect_type, effect_index)
		minetest.log("info", "Overriding effect '" .. effect.effect_name ..
				"' granted by '" .. effect.source .. "' on player '" .. player_name .. "'")
	end

	if effect.text_influence then
		-- local s = effect.text_influence:split(' ')
		-- effect.influence = player_properties.influence_functions[s[1]](tonumber(s[2]))
		effect.influence = assert(loadstring("return " .. effect.text_influence))()
	end

	table.insert(player_effect_type, effect)
	table.sort(player_effect_type, sort_effects)
	update_property(player, effect.effect_name)
end

local function print_po(po)
	for k, v in pairs(po) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : '" .. tostring(v) .. "'")
	end
end



local function init_player_properties(player)
	local player_name = player:get_player_name()
	local players_effects = {}

	for property_name, _ in pairs(registered_properties) do
		players_effects[property_name] = {}
	end

	players[player_name] = players_effects
end

local function load_persisted_effects(player)
	local meta = player:get_meta()
	assert(meta, "There is no meta for player: " .. player:get_player_name())
	local effect_string = meta:get_string("persistant_effects")
	meta:set_string("persistant_effects", "")
	-- print(effect_string)
	if effect_string ~= "" then
		effect_string = minetest.deserialize(effect_string, false)
		for _, effect in pairs(effect_string) do
			player_properties.add_effect(player, effect)
		end
	end
end

minetest.register_on_joinplayer(function(player, last_login)
	init_player_properties(player)

	load_persisted_effects(player)
end)

local function save_player_data(player)
	local player_name = player:get_player_name()

	local meta = player:get_meta()

	local t = {}
	for effect_type, effects in pairs(players[player_name]) do
		for _, effect in ipairs(effects) do
			if effect.persistant then
				effect.influence = string.dump(effect.influence)
				table.insert(t, effect)
			end
		end
	end

	t = minetest.serialize(t)
	meta:set_string("persistant_effects", t)

	players[player_name] = nil
end

minetest.register_on_leaveplayer(function(player, timed_out)
	save_player_data(player)
end)

minetest.register_on_shutdown(function()
	for _, player in pairs(minetest.get_connected_players()) do
		save_player_data(player)
	end
end)

-- tick down timed effects
local timer = 0
local update_hud = false
minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer > 1 then
		timer = timer - 1
	    for _, player in pairs(minetest.get_connected_players()) do
			update_hud = false
			local player_name = player:get_player_name()
			for effect_type, effects in pairs(players[player_name]) do
				for _, effect in ipairs(effects) do
					if effect.timeout then
						update_hud = true
						effect.timeout = effect.timeout - 1
						if effect.timeout <= 0 then
							player_properties.remove_effect(player, effect.effect_name, effect.source)
							if effect.on_timeout then
								effect.on_timeout(player)
							end
						end
					end
				end
			end
			if update_hud then
				player_properties.show_effect_hud(player, players[player_name])
			end
	    end
	end
end)
