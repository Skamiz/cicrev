local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()



minetest.register_chatcommand("dungeon", {
	params = "<dungeon data file> <schematic 1> <schematic 2> ... ",
	description = "Place dungeon. First argumet is a lua file specifying the structure. Following arguments are schematics to be used.",
	privs = {server = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local params = param:split(" ")

		local map = dofile(modpath .. "/dungeons/" .. params[1] .. ".lua")
		local minp = player:get_pos():round()
		minp.x = minp.x - (minp.x%3)
		minp.y = minp.y - (minp.y%3)
		minp.z = minp.z - (minp.z%3)

		local i = 0
		for z = map.size.z, 1, -1 do
			for x = 1, map.size.x do
				i = i + 1
				minetest.place_schematic(
						{x = minp.x + 3*x, y = minp.y, z = minp.z + 3*z},
						modpath .. "/schems/" .. params[map.data[i] + 1] .. ".mts",
						"0",
						nil,
						true)
			end
		end
	end,
})
minetest.register_chatcommand("fov", {
	params = "<val>",
	description = "Set player FOV property.",
	privs = {},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local fov = tonumber(param)
		if fov then
			player:set_fov(fov, nil, 1)
		end
	end,
})
minetest.register_chatcommand("offs", {
	params = "<val>",
	description = "Set player camera offset property.",
	privs = {},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local offs = tonumber(param)
		if offs then
			player:set_eye_offset(vector.new(0, 0, offs))
		end
	end,
})
minetest.register_chatcommand("fog", {
	params = "<val>",
	description = "Set player fog property.",
	privs = {},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		player:set_sky({
			base_color = param,
			type = "plain",
			-- fog = {
			--
			-- },
		})
	end,
})
