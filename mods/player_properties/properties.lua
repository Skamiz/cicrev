

















player_properties.register_property({
	name = "speed",
	default_value = 1,
	set = function(player, value)
		player:set_physics_override({speed = value})
	end,
})

player_properties.register_property({
	name = "jump",
	default_value = 1,
	set = function(player, value)
		player:set_physics_override({jump = value})
	end,
})
