--[[
This implements a mechanic by which the player speed can be varied depending on
what the player is standing on.

To use just add the group 'walkover_speed' to your node with percentage value by
which to modify the speed.

ex.: walkover_speed = 50 -- will cut down the movement speed to half


Since this runs in 'globalstep' optimization is important here.
--]]

local players = {}
local nodes = {}

-- nodes which use this mechanic are cached here to shorten lookup time
minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if def.groups.walkover_speed then
			nodes[name] = def.groups.walkover_speed * 0.01
		end
	end
end)

minetest.register_globalstep(function(dtime)
    for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
        local pos = player:get_pos()
        pos.y = pos.y - 0.1
		pos = vector.round(pos)
        local node = minetest.get_node(pos)
		local walkover_speed = nodes[node.name]

		if walkover_speed then
			-- only do something if the value actually changes
			if walkover_speed ~= players[name] then
				player_properties.add_effect(player, {
					source = "walkover_speed",
					effect_name = "speed",
					influence = function(speed) return speed * walkover_speed end,
					priority = 120,
				})
				players[name] = walkover_speed
			end
		-- maintian last speed while in air
		elseif minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].walkable and players[name] then
			player_properties.remove_effect(player, "speed", "walkover_speed")
			players[name] = nil
		end
    end
end)
