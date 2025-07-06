local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

mapgen = {}
mapgen.mod_storage = minetest.get_mod_storage()

-- TODO: consider putting content ID's in their own file, maybe into the table 'c'

dofile(modpath .. "/util.lua")

minetest.set_mapgen_setting("water_level", "0", true)

mapgen.delete_world = function()
	local worldpath = minetest.get_worldpath()
	minetest.rmdir(worldpath .. "/map.sqlite", false)
end


if mapgen.mod_storage:contains("mapgen_override") then
	local override = mapgen.mod_storage:get_string("mapgen_override")
	dofile(modpath .. "/" .. override  .. ".lua")
else
	-- dofile(modpath .. "/make_frame.lua")
	-- dofile(modpath .. "/flat.lua")

	-- dofile(modpath .. "/mount_meru.lua")
	-- dofile(modpath .. "/mesa.lua")
	-- dofile(modpath .. "/yaml_1.lua")
	-- dofile(modpath .. "/edge_distance.lua")
	-- dofile(modpath .. "/pudles.lua")
	-- dofile(modpath .. "/undersampling.lua")
	-- dofile(modpath .. "/coastline.lua")
	-- dofile(modpath .. "/island.lua")
	-- dofile(modpath .. "/shrooms.lua")
	-- dofile(modpath .. "/procedural_fortress.lua")
	-- dofile(modpath .. "/frac.lua")
	-- dofile(modpath .. "/caelid.lua")
	-- dofile(modpath .. "/forest.lua")
	-- dofile(modpath .. "/basal.lua")
	-- dofile(modpath .. "/rings.lua")
	-- dofile(modpath .. "/mc.lua")
	-- dofile(modpath .. "/karst.lua")
	-- dofile(modpath .. "/caverns.lua")
	-- dofile(modpath .. "/layer_transition.lua")
	-- dofile(modpath .. "/mountains.lua")
	-- dofile(modpath .. "/plateaus.lua")
	-- dofile(modpath .. "/offset.lua")
	dofile(modpath .. "/concentric.lua")
	-- dofile(modpath .. "/mapgen_env.lua")
	-- minetest.register_mapgen_script(modpath .. "/mapgen_env.lua")

	-- dofile(modpath .. "/template_vanilla.lua")
	-- minetest.register_mapgen_script(modpath .. "/template_vanilla.lua")

	-- dofile(modpath .. "/ore_veins.lua")
	-- dofile(modpath .. "/caves.lua")
	-- dofile(modpath .. "/template.lua")
	-- dofile(modpath .. "/fake3d.lua")
	-- dofile(modpath .. "/template_async.lua")
	-- dofile(modpath .. "/noise_research.lua")
	-- dofile(modpath .. "/test.lua")
	-- mapgen.delete_world()
end


minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm = minetest.get_mapgen_object("voxelmanip")
    minetest.generate_decorations(vm)
	minetest.generate_ores(vm)
	vm:update_liquids()
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:write_to_map()
end)

minetest.register_chatcommand("sphere", {
	func = function(name, param)
		local schem = u.get_sphere_schematic(tonumber(param), {name = "df_stones:gneiss"})
		local player = minetest.get_player_by_name(name)
		-- for i = 1, tonumber(param) do
		-- 	minetest.after(i/2, minetest.place_schematic, player:get_pos(), u.get_sphere_schematic(i/10, {name = "df_stones:gneiss"}),
		-- 		"0", replacement, true, "place_center_x, place_center_y, place_center_z")
		--
		-- end
		minetest.place_schematic(player:get_pos(), schem,
			"0", replacement, true, "place_center_x, place_center_y, place_center_z")
	end
})

minetest.register_chatcommand("deletechunk", {
	params = "",
	description = "Delete map chunk player currently occupies, causing it to regenerate.",
	privs = {server=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		local pos = player:get_pos():round()
		local minp = {x = 80 * math.floor((pos.x + 32) / 80) - 32,
					y = 80 * math.floor((pos.y + 32) / 80) - 32,
					z = 80 * math.floor((pos.z + 32) / 80) - 32}
		local maxp = {x = minp.x + 79, y = minp.y + 79, z = minp.z + 79}

		if minetest.delete_area(minp, maxp) then
			return true, "Successfully cleared chunk ranging from " ..
				minetest.pos_to_string(minp, 1) .. " to " .. minetest.pos_to_string(maxp, 1)
		else
			return false, "Failed to clear one or more blocks in area"
		end
	end,
})

minetest.register_chatcommand("mapgen_override", {
	params = "[mapgen file]",
	description = "Override file from which mapgen is loaded. Only takes effect on world reload.",
	privs = {server = true},
	func = function(name, param)
		mapgen.mod_storage:set_string("mapgen_override", param)
	end,
})
