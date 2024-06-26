local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

mapgen = {}
mapgen.mod_storage = minetest.get_mod_storage()

-- TODO: consider putting content ID's in their own file, maybe into the table 'c'

dofile(mod_path.."/util.lua")
dofile(mod_path.."/cartography.lua")
-- dofile(mod_path.."/make_frame.lua")
-- dofile(mod_path.."/flat.lua")

-- dofile(mod_path.."/mount_meru.lua")
-- dofile(mod_path.."/mesa.lua")
-- dofile(mod_path.."/yaml_1.lua")
-- dofile(mod_path.."/edge_distance.lua")
-- dofile(mod_path.."/pudles.lua")
-- dofile(mod_path.."/undersampling.lua")
-- dofile(mod_path.."/coastline.lua")
-- dofile(mod_path.."/island.lua")
-- dofile(mod_path.."/shrooms.lua")
-- dofile(mod_path.."/procedural_fortress.lua")
-- dofile(mod_path.."/frac.lua")
-- dofile(mod_path.."/caelid.lua")
-- dofile(mod_path.."/forest.lua")
-- dofile(mod_path.."/basal.lua")
-- dofile(mod_path.."/rings.lua")
-- dofile(mod_path.."/mc.lua")
-- dofile(mod_path.."/karst.lua")
-- dofile(mod_path.."/caverns.lua")
-- dofile(mod_path.."/layer_transition.lua")
-- dofile(mod_path.."/mountains.lua")
-- dofile(mod_path.."/plateaus.lua")
-- dofile(mod_path.."/offset.lua")
dofile(mod_path.."/concentric.lua")

-- dofile(mod_path.."/ore_veins.lua")
-- dofile(mod_path.."/caves.lua")
-- dofile(mod_path.."/template.lua")
-- dofile(mod_path.."/fake3d.lua")
-- dofile(mod_path.."/template_async.lua")
-- dofile(mod_path.."/noise_research.lua")
-- dofile(mod_path.."/test.lua")
-- dofile(mod_path.."/delete_map.lua")



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
