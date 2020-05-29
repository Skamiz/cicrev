local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

dofile(mod_path.."/util.lua")
-- dofile(mod_path.."/cave_util.lua")
dofile(mod_path.."/clear_chunk.lua")
-- dofile(mod_path.."/make_frame.lua")
-- dofile(mod_path.."/mesa.lua")
-- dofile(mod_path.."/yaml_1.lua")
dofile(mod_path.."/edge_distance.lua")
-- dofile(mod_path.."/caves.lua")
-- dofile(mod_path.."/undersampling.lua")
-- dofile(mod_path.."/coastline.lua")



minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm = minetest.get_mapgen_object("voxelmanip")
    minetest.generate_decorations(vm)
	vm:update_liquids()
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
