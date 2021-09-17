local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()

minetest.register_chatcommand("place_dungeon", {
	params = "",
	description = "Places a dungeon level",
	privs = {server=true},
	func = function(name, param)
		local schematic = minetest.serialize_schematic(modpath .. "/schematics/theThing.lua", "lua", {lua_use_comments = true})
		local file_to, err = io.open(worldpath .. "/schematics/theThing.lua", "w")
		assert(file_to, err)
		file_to:write(schematic)
		io.close(file_to)
		-- local f, err = io.open(minetest.get_modpath("mg").."/schems/"..scm..".we", "r")
		-- if not f then
		-- 	error("Could not open schematic '" .. scm .. ".we': " .. err)
		-- end
	end,
})

minetest.register_chatcommand("dun", {
	params = "",
	description = "Generate decorations in current mapchunk.",
	privs = {server=true},
	func = function(name, param)
		local params = param:split(" ")
		-- for k, v in ipairs(params) do
		-- 	minetest.chat_send_all(v)
		-- end

		local map = dofile(modpath .. "/dungeons/" .. params[1] .. ".lua")
		-- local file_to, err = io.open(worldpath .. "/schematics/theThing.lua", "w")
		-- assert(file_to, err)
		local player = minetest.get_player_by_name(name)
		local minp = player:get_pos()
		minp.x = minp.x + 0.5
		minp.y = minp.y + 0.5
		minp.z = minp.z + 0.5
		minp.x = minp.x - (minp.x%3)
		minp.y = minp.y - (minp.y%3)
		minp.z = minp.z - (minp.z%3)

		local i = 0
		for z = map.size.z, 1, -1 do
			for x = 1, map.size.x do
				i = i + 1
				minetest.place_schematic({x = minp.x + 3*x,
				y = minp.y,
				z = minp.z + 3*z}, worldpath .. "/schems/" .. params[map.data[i] + 1] .. ".mts", "0", nil, true)
			end
		end

		-- local pos = player:get_pos()
		-- local minp = {x = 80 * math.floor((pos.x + 32) / 80) - 32,
		-- 			y = 80 * math.floor((pos.y + 32) / 80) - 32,
		-- 			z = 80 * math.floor((pos.z + 32) / 80) - 32}
		-- local maxp = {x = minp.x + 80, y = minp.y + 80, z = minp.z + 80}
		--
		-- local vm = minetest.get_voxel_manip()
		-- local emin, emax = vm:read_from_map(minp, maxp)
		--
		-- minetest.generate_decorations(vm, minp, maxp)
		--
		-- vm:write_to_map()
	end,
})
