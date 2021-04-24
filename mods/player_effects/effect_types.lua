player_effects.register_effect_type({
	name = "speed",
	default_value = 1,
	set = function(player, value)
		player:set_physics_override({speed = value})
	end,
})

player_effects.register_effect_type({
	name = "jump",
	default_value = 1,
	set = function(player, value)
		player:set_physics_override({jump = value})
	end,
})
