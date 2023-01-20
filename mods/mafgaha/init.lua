local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

mafgaha = {}

-- TODO: casting a spell doesn't update it's description

dofile(modpath .. "/runes.lua")
dofile(modpath .. "/spells.lua")

local function get_eye_pos(player)
	local player_pos = player:get_pos()
	local eye_height = player:get_properties().eye_height
	local eye_offset = player:get_eye_offset()

	-- player_pos.y = player_pos.y + eye_height
	return player_pos + eye_offset + vector.new(0, eye_height, 0)
end

local casters = {}

local function start_casting(player)
	local name = player:get_player_name()
	casters[name] = {
		player = player,
		last_ver = player:get_look_vertical(),
		last_hor = player:get_look_horizontal(),
		last_dir = "none",
		storkes = {},
	}
end

local function get_focus_description(focus)
	local meta = focus:get_meta()
	local sequence = meta:get_string("sequence")
	local s = string.split(sequence, ", ")
	local d = focus:get_short_description()
	for i, v in ipairs(s) do
		d = d .. "\n" .. v
	end
	meta:set_string("description", d)

end

local function finish_casting(player)
	local wand = player:get_wielded_item()
	local name = player:get_player_name()
	-- When casting came to an unnatural end
	if not wand:get_name():find(modname .. ":focus") then
		casters[name] = nil
		return
	end
	local cast = casters[name]
	local strokes = table.concat(cast.storkes)
	local rune = mafgaha.runes[strokes]
	if rune then
		local meta = wand:get_meta()
		local sequence = meta:get("sequence")
		if not sequence then
			sequence = rune.name
		else
			sequence = sequence .. ", " .. rune.name
		end
		minetest.chat_send_all("Stroke sequence is " .. sequence)
		meta:set_string("sequence", sequence)
		if mafgaha.spells[sequence] then
			wand:set_name(modname .. ":focus_charged")
		else
			wand:set_name(modname .. ":focus")
		end
		get_focus_description(wand)
		player:set_wielded_item(wand)
	end
	casters[name] = nil
end


minetest.register_craftitem(modname .. ":focus", {
	description = "Fokus",
	inventory_image = "mafgaha_wand.png",
	on_use = function(itemstack, user, pointed_thing)
		start_casting(user)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		itemstack:get_meta():set_string("sequence", "")
		return itemstack
	end,
})

minetest.register_craftitem(modname .. ":focus_charged", {
	description = "Charged Fokus",
	inventory_image = "mafgaha_wand_charged.png",
	on_use = function(itemstack, user, pointed_thing)
		start_casting(user)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		local meta = itemstack:get_meta()
		local sequence = meta:get_string("sequence")

		local spell = mafgaha.spells[sequence]
		if spell and spell.on_cast then
			spell.on_cast(user)
		end

		meta:set_string("sequence", "")
		itemstack:set_name(modname .. ":focus")
		return itemstack
	end,
})

local function angle_to_dir_4(angle)
	if angle < 45 then return "u"
	elseif angle < 135 then return "l"
	elseif angle < 225 then return "d"
	elseif angle < 315 then return "r"
	else return "u"
	end
end

local function angle_to_dir_8(angle)
	if angle < 22.5 then return "t"
	elseif angle < 67.5 then return "r"
	elseif angle < 112.5 then return "f"
	elseif angle < 157.5 then return "v"
	elseif angle < 202.5 then return "b"
	elseif angle < 247.5 then return "n"
	elseif angle < 292.5 then return "h"
	elseif angle < 337.5 then return "y"
	else return "t"
	end
end

local function get_dir(last_ver, last_hor, new_ver, new_hor)
	local d_ver = new_ver - last_ver
	local d_hor = new_hor - last_hor

	if d_ver == 0 and d_hor == 0 then return end

	-- acount for wraparound
	if math.abs(d_hor) > math.pi then
		d_hor = (-math.sign(d_hor) * 2 * math.pi + new_hor) - last_hor
	end

	-- angle is 0 at 12 o'clock and increases counter clock wise
	local angle = math.atan2(-d_hor, d_ver) + math.pi
	angle = math.deg(angle)
	return angle_to_dir_4(angle)
end

minetest.register_globalstep(function(dtime)
	for name, cast in pairs (casters) do
		local player = cast.player
		if (not player:get_player_control().dig) or not player:get_wielded_item():get_name():find(modname .. ":focus") then
			finish_casting(player)
		end

		-- particles
		local start_pos = get_eye_pos(player)
		local look_dir = player:get_look_dir()
		minetest.add_particle({
			pos = start_pos + look_dir,
			expirationtime = 2,
			texture = "mafgaha_particle.png",
			glow = 0,
		})

		-- actual mechanics
		local new_ver = player:get_look_vertical()
		local new_hor = player:get_look_horizontal()

		local new_dir = get_dir(cast.last_ver, cast.last_hor, new_ver, new_hor)

		cast.last_ver = new_ver
		cast.last_hor = new_hor

		if new_dir and new_dir ~= cast.last_dir then
			table.insert(cast.storkes, new_dir)
			cast.last_dir = new_dir
		end
	end
end)
