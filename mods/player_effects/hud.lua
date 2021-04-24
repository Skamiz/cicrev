-- hud_add(hud definition)
-- maybe just pack everything in one label if possible?
local players = {}

local function get_effect_string(player, players_effects)
	local s = ""
	for effect_type, effects in pairs(players_effects) do
		if effects[1] then
			s = s .. effect_type .. "\n"
		end
		for i, effect in ipairs(effects) do
			s = s .. "	" .. effect.priority .. " - " .. effect.source .. "\n"
		end
	end
	return s
end

function player_effects.show_effect_hud(player, players_effects)
	local player_name = player:get_player_name()
	local effect_string = get_effect_string(player, players_effects)

	if not players[player_name] then
		players[player_name] = player:hud_add({
			hud_elem_type = "text",
			position = {x=0.5, y=0.5},
			alignment = {x=1, y=1},
			text = effect_string,
		})
	else
		player:hud_change(players[player_name], "text", effect_string)
	end
end

function player_effects.hide_effect_hud(player)
	local player_name = player.get_player_name()
	player:hud_remove(players[player_name])
	players[player_name] = nil
end
