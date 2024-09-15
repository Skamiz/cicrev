--[[
TODO: placement functions
]]
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

shapes = {}
-- disatnce from center of a node face which causes slabs to be placed rotated
shapes.orthogonal_slab_margin = 4/16

function shapes.add_group(def, group, rating)
	if not def.groups[group] then
		def.groups[group] = rating
	end
end

shapes.place = {}
dofile(modpath .. "/pointed_pos.lua")
dofile(modpath .. "/placer_functions.lua")

shapes.register = {}
dofile(modpath .. "/shapes/stair.lua")
dofile(modpath .. "/shapes/slab.lua")
dofile(modpath .. "/shapes/wedge.lua")

dofile(modpath .. "/shapes/panel.lua")
dofile(modpath .. "/shapes/pillar.lua")

dofile(modpath .. "/shapes/fence.lua")
dofile(modpath .. "/shapes/wall.lua")
dofile(modpath .. "/shapes/pane.lua")


dofile(modpath .. "/test_node.lua")

shapes.register.quaters = function(name, def)
	local stair_def = table.copy(def)
	stair_def.description = stair_def.description .. " Stair"
	shapes.register.stair(name .. "_stair", stair_def)
	local slab_def = table.copy(def)
	slab_def.description = slab_def.description .. " Slab"
	shapes.register.slab(name .. "_slab", slab_def)
	local wedge_def = table.copy(def)
	wedge_def.description = wedge_def.description .. " Wedge"
	shapes.register.wedge(name .. "_wedge", wedge_def)
end


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
