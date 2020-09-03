--[[
	A place for deving new code bofore deciding what to do with it.
]]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()


minetest.register_craftitem("cicrev:axe_of_debug", {
	description = "axe of debug",
	inventory_image = "cicrev_axe_of_trees.png",
	wield_image = "cicrev_axe_of_trees.png",
	stack_max = 1,
	tool_capabilities = {
		groupcaps = {
			test = {maxlevel=0, uses=20, times={[1]=1, [2]=2, [3]=3, [4]=4}},
		},
	},
	on_place = function(itemstack, placer, pointed_thing)
		dofile(worldpath .. "/schems/theThing.lua")
		minetest.place_schematic(pointed_thing.above, schematic, "random", replacements, force_placement, flags)
	end,
	on_use = function(itemstack, user, pointed_thing)
		-- causes crash for some reason
		local pos = user:get_pos()
		-- local minp = {x = pos.x - 16, y = pos.y - 16, z = pos.z - 16}
		-- local maxp = {x = pos.x + 16, y = pos.y + 16, z = pos.z + 16}

		local minp = {x = 0, y = 0, z = 0}
		local maxp = {x = minp.x + 5, y = minp.y + 5, z = minp.z + 5}

		local vm = minetest.get_voxel_manip(minp, maxp)
		-- local emin, emax = vm:read_from_map(minp, maxp)

		minetest.generate_decorations(vm, minp, maxp)

		vm:write_to_map()
	end,
})

minetest.register_node("cicrev:test_node_1", {
	description = "test_node_1",
	tiles = {"test_node_1.png"},
	groups = {test = 1},
})
minetest.register_node("cicrev:test_node_2", {
	description = "test_node_2",
	tiles = {"test_node_2.png"},
	groups = {test = 2},
})
minetest.register_node("cicrev:test_node_3", {
	description = "test_node_3",
	tiles = {"test_node_3.png"},
	groups = {test = 3},
})
minetest.register_node("cicrev:test_node_4", {
	description = "test_node_4",
	tiles = {"test_node_4.png"},
	groups = {test = 4},
})
