
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
dofile(modpath .. "/misc.lua")
dofile(modpath .. "/trees.lua")
dofile(modpath .. "/abms.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/craftitems.lua")
dofile(modpath .. "/tools.lua")
dofile(modpath .. "/crafts.lua")
dofile(modpath .. "/mapgen.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/debug.lua")
dofile(modpath .. "/growing_trees.lua")



minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		minetest.override_item(name,{
			stack_max = 8,
		})
	end
	for name, def in pairs(minetest.registered_craftitems) do
		minetest.override_item(name,{
			stack_max = 16,
		})
	end
end)
