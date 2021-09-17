
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
dofile(modpath .. "/misc.lua")
dofile(modpath .. "/trees.lua")
dofile(modpath .. "/abms.lua")
dofile(modpath .. "/nodes.lua")
dofile(modpath .. "/craftitems.lua")
dofile(modpath .. "/tools.lua")
dofile(modpath .. "/crafts.lua")
-- dofile(modpath .. "/mapgen.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/debug.lua")
dofile(modpath .. "/growing_trees.lua")


minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		local groups = table.copy(def.groups)
		groups["everything"] = 1
		minetest.override_item(name,{
			groups = groups,
		})

		if not rawget(def, "stack_max") then
			minetest.override_item(name,{
				stack_max = 8,
			})
		end

		if def.drawtype == "normal" and def.walkable then
			local groups = table.copy(def.groups)
			groups["solid_node"] = 1
			minetest.override_item(name,{
				groups = groups,
			})
		end
	end
	for name, def in pairs(minetest.registered_craftitems) do
		if not rawget(def, "stack_max") then
			minetest.override_item(name,{
				stack_max = 16,
			})
		end
	end
end)
