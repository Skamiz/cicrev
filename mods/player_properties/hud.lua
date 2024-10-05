-- hud_add(hud definition)
-- maybe just pack everything in one label if possible?
local players = {}
local player_huds = {}

--[[
local function get_effect_string(effect)
	local s = {
		effect.priority or "[effect_priority]",
		" - ",
		effect.name or "[effect_name]",
		" - ",
		effect.duration or " ",
		" - ",
		tostring(effect.persistant) or "false",
	}
	return table.concat(s)
end

local function get_effects_string(player, players_effects)
	local s = {}
	for property, effects in pairs(players_effects) do
		if effects[1] then
			table.insert(s, property)
			table.insert(s, "\n\t")
		end
		for i, effect in ipairs(effects) do
			table.insert(s, get_effect_string(effect))
			table.insert(s, "\n\t")
		end
	end
	s = table.concat(s)
	return s
end

function player_properties.show_effect_hud(player, players_effects)
	local player_name = player:get_player_name()
	local effect_string = get_effects_string(player, players_effects)

	if not players[player_name] then
		players[player_name] = player:hud_add({
			type = "text",
			position = {x=0.5, y=0.5},
			alignment = {x=1, y=1},
			text = effect_string,
		})
	else
		player:hud_change(players[player_name], "text", effect_string)
	end
end

function player_properties.hide_effect_hud(player)
	local player_name = player.get_player_name()
	player:hud_remove(players[player_name])
	players[player_name] = nil
end
]]

local function get_effect_hud(effect, y_offset)
	local effect_hud = {}
	effect_hud.icon = {
		type = "image",
		position = {x = 1, y = 0},
		alignment = {x = -1, y = 1},
		offset = {x = 0, y = 0 + y_offset},
		scale = {x = 4, y = 4},
		text = effect.icon,
	}
	if effect.duration then
		effect_hud.timer = {
			type = "text",
			position = {x = 1, y = 0},
			alignment = {x = 0, y = 1},
			offset = {x = -32, y = 64 + y_offset},
			number = 0xFFFFFF,
			text = effect.duration .. " s",
		}
	end
	return effect_hud
end

local function remove_effect_huds(player)
	for hud_name, hud_id in pairs(player_huds[player] or {}) do
		player:hud_remove(hud_id)
	end
end

function player_properties.update_effect_huds(player)
	remove_effect_huds(player)
	local huds = {}
	local properties = player_properties.players[player:get_player_name()]
	local n = 0

	for property, effects in pairs(properties) do
		for i, effect in ipairs(effects) do
			if effect.icon then
				local effect_huds = get_effect_hud(effect, n * 96)
				n = n + 1
				huds[effect.property .. effect.name .. "icon"] = player:hud_add(effect_huds.icon)
				if effect_huds.timer then
					huds[effect.property .. effect.name .. "timer"] = player:hud_add(effect_huds.timer)
				end
				-- table.insert(huds[effect.property .. effect.name], get_effect_hud(effect))
			end
		end
	end
	player_huds[player] = huds
end

-- minetest.register_globalstep(function(dtime)
-- 	for _, player in pairs(minetest.get_connected_players()) do
-- 		player_properties.update_effect_huds(player)
-- 	end
-- end)
