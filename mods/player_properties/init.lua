local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)


--[[

terminlogy:
player_properties - mod name, name of main table
player_properties - effects currently applied to a player


property - that can be affected through effects
	name
	default_value
	set - function that sets final property value
effect - a specific effect like the speed boost of a pair of boots
	name
	property - that is influenced
	-- description
	-- icon
	influence
	persistent
	text_influence
	priority
	duration
	on_timeout


player_properties.register_property(property_name, {
	description = "Speed",
	default_value = 1,
	set = function(player, value)
		player:set_physics_override({speed = value})
	end,
})


player_properties.add_effect(player, {
	name = "rune", -- same name will override previous effect
	property = "speed", -- property to which effect is applied
	-- WARNING:functions can't be persisted across restarts
	influence = function(speed) return speed * walkover_speed end,
	persistent = true, -- if true text_infuelce is required
	text_influence = "function (s) return s + 0.5 end", -- overrides 'influence'
	priority = 80,
	duration = 30, -- in seconds
	on_timeout = function(player) end,
})

can specify a duration of the effect
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
- a curse which damages health on timeout and restarts with a shorter duration

Concepts:
- exchanging one stat for another eg. more speed, but no jumping


--]]

player_properties = {}
-- local registered_properties = {}
local players = {}
player_properties.players = players

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



dofile(modpath .. "/properties.lua")
dofile(modpath .. "/effects.lua")
dofile(modpath .. "/hud.lua")
dofile(modpath .. "/commands.lua")

dofile(modpath .. "/walkover_speed.lua")



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
			for property, effects in pairs(players[player_name]) do
				for _, effect in ipairs(effects) do
					if effect.duration then
						update_hud = true
						effect.duration = effect.duration - 1
						if effect.duration <= 0 then
							player_properties.remove_effect(player, effect.property, effect.name)
							if effect.on_timeout then
								effect.on_timeout(player)
							end
						end
					end
				end
			end
			if update_hud then
				-- player_properties.show_effect_hud(player, players[player_name])
				player_properties.update_effect_huds(player)
			end
	    end
	end
end)
