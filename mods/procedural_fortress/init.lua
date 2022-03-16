local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

if true then return end

local np_fort = {
		offset = 2,
		scale = 5,	-- affects how many levels total there are
		spread = {x = 40, y = 40, z = 40}, -- affects how spread out the overall structure is
		seed = 0,
		octaves = 1,
		persist = 1,
		lacunarity = 1.0,
		flags = "noeased,absvalue",
}

proc_fort = {
	section_height = 5,
	section_size = 8, -- TODO: sometimes it fails to load schematics if the size is 3
	nobj_fort = noise_handler.get_noise_object(np_fort),
}

dofile(modpath.."/fortress_gen.lua")
dofile(modpath.."/fortress_pieces.lua")
dofile(modpath.."/mapgen.lua")
dofile(modpath.."/tools.lua")



minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm = minetest.get_mapgen_object("voxelmanip")
    minetest.generate_decorations(vm)
	minetest.generate_ores(vm)
	vm:update_liquids()
	vm:set_lighting({day = 0, night = 0})
	vm:calc_lighting()
	vm:write_to_map()
end)
