
local players = {}

local regen = {}
regen.base_rate = 0.1 -- per second
regen.players = players


function regen.add_player(player)
	players[player] = 0
	local meta = player:get_meta()
	meta:set_float("regen_rate", regen.base_rate)
end

function regen.remove_player(player)
	players[player] = nil
end

function regen.heal(player, amount)
	local health = player:get_hp()
	health = health + amount
	player:set_hp(health, "regeneration")
end

function regen.tick(dtime)
	for player, _ in pairs(players) do
		local timer = players[player]
		timer = timer + dtime

		local meta = player:get_meta()
		local regen_rate = meta:get_float("regen_rate")
		local regen_time = 1 / regen_rate

		if timer >= regen_time then
			timer = timer - regen_time
			regen.heal(player, 1)
		end

		players[player] = timer
	end
end







minetest.register_on_joinplayer(regen.add_player)

minetest.register_globalstep(regen.tick)

minetest.register_on_leaveplayer(regen.remove_player)
