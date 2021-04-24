local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)


-- TODO: implement this mod
--[[
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
	influence = function(value) return modified_value end
	priority = n, -- order of effect evaluation
	time = n, -- in seconds
	persistent = false/true,
	callback_on_timeout = funciton,
}

local e = effect(player, effect)
e:stop() -- stops the effect


-- on initialization set all values to default_value, since it might differ from the default minetest value

--]]

player_effects = {}
local effect_types = {}
local players = {}

function player_effects.register_effect_type(effect_type)
	assert(not effect_types[effect_type.name], "Effect: '" .. effect_type.name .. "' already exists")
	effect_types[effect_type.name] = effect_type
end

dofile(modpath .. "/effect_types.lua")
dofile(modpath .. "/hud.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/wlakover_speed.lua")

local function update_effect_type(player, effect_name)
	local effect_type = effect_types[effect_name]
	local player_name = player:get_player_name()
	local players_effects = players[player_name]

	local effect_strength = effect_type.default_value
	for i, v in ipairs(players_effects[effect_name]) do
		-- rename this to effect_infuluence
		effect_strength = v.influence(effect_strength)
	end
	effect_type.set(player, effect_strength)

	player_effects.show_effect_hud(player, players_effects)
end

-- from table t find index of element for which source == effect_source
local function get_index(t, source)
	for i, effect in ipairs(t) do
		if effect.source == source then
			return i
		end
	end
end

function player_effects.remove_effect(player, effect_name, effect_source)
	local player_name = player:get_player_name()
	local player_effect_type = players[player_name][effect_name]

	local effect_index = get_index(player_effect_type, effect_source)
	if effect_index then
		table.remove(player_effect_type, effect_index)
		update_effect_type(player, effect_name)
	else
		minetest.log("info", "Trying to remove nonexistent effect '" .. effect_name ..
				"' granted by '" .. effect_source .. "' on player '" .. player_name .. "'")
	end
end

local function sort_effects(e1, e2)
	return e1.priority < e2.priority
end

function player_effects.add_effect(player, effect)
	local player_name = player:get_player_name()
	local player_effect_type = players[player_name][effect.effect_name]

	local effect_index = get_index(player_effect_type, effect.source)
	if effect_index then
		table.remove(player_effect_type, effect_index)
		minetest.log("info", "Overriding effect '" .. effect.effect_name ..
				"' granted by '" .. effect.source .. "' on player '" .. player_name .. "'")
	end

	table.insert(player_effect_type, effect)
	table.sort(player_effect_type, sort_effects)
	update_effect_type(player, effect.effect_name)
end

minetest.register_on_joinplayer(function(player, last_login)
	local player_name = player:get_player_name()
	local players_effects = {}

	for effect_name, _ in pairs(effect_types) do
		players_effects[effect_name] = {}
	end

	players[player_name] = players_effects
end)

minetest.register_on_leaveplayer(function(player, timed_out)
	local player_name = player:get_player_name()
	-- TODO: make sure that timeout callbacks aren't called
	players[player_name] = nil

	-- TODO: store persistent effects
end)
