-- sort effects by their priority
local function sort_effects(e1, e2)
	return e1.priority < e2.priority
end

-- from table t find index of element for which effect.name == effect_name
local function get_effect_index(t, effect_name)
	for i, effect in ipairs(t) do
		if effect.name == effect_name then
			return i
		end
	end
end


function player_properties.add_effect(player, effect)
	local player_name = player:get_player_name()
	local effect = table.copy(effect)
	local player_poperty_effects = player_properties.players[player_name][effect.property]
	assert(player_poperty_effects, dump(effect))

	local effect_index = get_effect_index(player_poperty_effects, effect.name)
	if effect_index then
		table.remove(player_poperty_effects, effect_index)
		minetest.log("info", "Overriding effect '" .. effect.property ..
				"' granted by '" .. effect.name .. "' on player '" .. player_name .. "'")
	end

	if effect.text_influence then
		effect.influence = assert(loadstring("return " .. effect.text_influence))()
	end

	table.insert(player_poperty_effects, effect)
	table.sort(player_poperty_effects, sort_effects)
	player_properties.update_property(player, effect.property)
	player_properties.update_effect_huds(player)
end

function player_properties.remove_effect(player, property_name, effect_name)
	local player_name = player:get_player_name()
	local player_poperty_effects = player_properties.players[player_name][property_name]

	local effect_index = get_effect_index(player_poperty_effects, effect_name)
	if effect_index then
		table.remove(player_poperty_effects, effect_index)
		player_properties.update_property(player, property_name)
		player_properties.update_effect_huds(player)
	else
		minetest.log("info", "Trying to remove nonexistent effect '" .. effect_name ..
				"' affecting '" .. property_name .. "' on player '" .. player_name .. "'")
	end
end



local function load_persisted_effects(player)
	local meta = player:get_meta()
	-- assert(meta, "There is no meta for player: " .. player:get_player_name())
	local effect_string = meta:get_string("persistent_effects")
	meta:set_string("persistent_effects", "")
	-- print(effect_string)
	if effect_string ~= "" then
		local effects = minetest.deserialize(effect_string, false)
		for _, effect in pairs(effects) do
			player_properties.add_effect(player, effect)
		end
	end
end
minetest.register_on_joinplayer(load_persisted_effects)

local function save_persistent_effects(player)
	local player_name = player:get_player_name()
	local meta = player:get_meta()

	local t = {}
	for effect_type, effects in pairs(player_properties.players[player_name]) do
		for _, effect in ipairs(effects) do
			if effect.persistant then
				effect.influence = string.dump(effect.influence)
				table.insert(t, effect)
			end
		end
	end

	t = minetest.serialize(t)
	meta:set_string("persistent_effects", t)

	player_properties.players[player_name] = nil
end

minetest.register_on_leaveplayer(function(player, timed_out)
	save_persistent_effects(player)
end)

minetest.register_on_shutdown(function()
	for _, player in pairs(minetest.get_connected_players()) do
		save_persistent_effects(player)
	end
end)
