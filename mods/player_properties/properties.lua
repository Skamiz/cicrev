


local registered_properties = {}
player_properties.registered_properties = registered_properties

-- register property to be managed
function player_properties.register_property(property_name, property)
	assert(not registered_properties[property_name], "Effect: '" .. property_name .. "' already exists")
	property.name = property_name
	registered_properties[property_name] = property
end

-- recalculate value of a property
function player_properties.update_property(player, property_name)
	local property = registered_properties[property_name]
	local player_name = player:get_player_name()
	local players_effects = player_properties.players[player_name]

	local effect_strength = property.default_value
	for _, effect in ipairs(players_effects[property_name]) do
		effect_strength = effect.influence(effect_strength)
	end
	property.set(player, effect_strength)
end

-- init empty property tables
local function init_player_properties(player)
	local player_name = player:get_player_name()
	local players_effects = {}
	player_properties.players[player_name] = players_effects

	for property_name, _ in pairs(registered_properties) do
		players_effects[property_name] = {}
		-- set to default_value on init
		player_properties.update_property(player, property_name)
	end

end
minetest.register_on_joinplayer(init_player_properties)







-- Default properties
player_properties.register_property("speed", {
	description = "Speed",
	default_value = 1,
	set = function(player, value)
		player:set_physics_override({speed = value})
	end,
})

player_properties.register_property("jump", {
	description = "Jump Height",
	default_value = 1,
	set = function(player, value)
		player:set_physics_override({jump = value})
	end,
})
