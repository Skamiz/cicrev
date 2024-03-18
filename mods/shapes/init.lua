local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

shapes = {}

function shapes.add_group(def, group, rating)
	if not def.groups[group] then
		def.groups[group] = rating
	end
end

shapes.place = {}
-- dofile(modpath .. "/placer_functions.lua")

shapes.register = {}
dofile(modpath .. "/shapes/stair.lua")
dofile(modpath .. "/shapes/slab.lua")
dofile(modpath .. "/shapes/wedge.lua")

dofile(modpath .. "/shapes/fence.lua")
dofile(modpath .. "/shapes/wall.lua")
dofile(modpath .. "/shapes/pane.lua")


dofile(modpath .. "/test_node.lua")


-- so connective nodes can attach to full nodes
minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_nodes) do
		if def.drawtype == "normal" and def.walkable then
			local groups = table.copy(def.groups)
			groups["solid_node"] = 1
			minetest.override_item(name,{
				groups = groups,
			})
		end
	end
end)
