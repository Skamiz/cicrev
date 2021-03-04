--[[
	A place for deving new code bofore deciding what to do with it.
]]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()

local x_rot = {
	13, 14, 15, 7, 4, 5, 6, 9,
	10, 11, 8, 20, 21, 22, 23, 0,
	1, 2, 3, 16, 17, 18, 19, 12,
}
local function rotate_towards_x(pos)
	local node = minetest.get_node(pos)
	node.param2 = x_rot[node.param2] or 12
	minetest.set_node(pos, node)
end

local z_rot = {
	5, 6, 7, 22, 23, 20, 21, 0,
	1, 2, 3, 13, 14, 15, 12, 19,
	16, 17, 18, 10, 11, 8, 9, 4,
}
local function rotate_towards_z(pos)
	local node = minetest.get_node(pos)
	node.param2 = z_rot[node.param2] or 4
	minetest.set_node(pos, node)
end

minetest.register_entity(modname .. ":debug_object", {
	initial_properties = {
		visual = "item",
		visual_size = {x = 2/3, y = 2/3, z = 2/3},
		physical = true,
		static_save = false,
		wield_item = "df_stones:slate_chiseled_3_1",
	},
	-- rotation hirearchy is y > x > z
	on_activate = function(self, staticdata, dtime_s)
		local rot = self.object:get_rotation()
		-- rot.x = rot.x + ((math.pi / 2))
		-- rot.y = rot.y + ((math.pi / 2))
		-- rot.z = rot.z + ((math.pi / 2))
		self.object:set_rotation(rot)
	end,
	on_step = function(self, dtime, moveresult)
		local rot = self.object:get_rotation()
		-- rot.x = rot.x + ((math.pi / 2) * (dtime))
		rot.y = rot.y + ((math.pi / 2) * (dtime))
		-- rot.z = rot.z + ((math.pi / 2) * (dtime))
		self.object:set_rotation(rot)
	end,
})

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
	-- TODO: see how droping node objects interact when spawned right on top of each other
	on_place = function(itemstack, placer, pointed_thing)
		local node_obj = minetest.add_entity(pointed_thing.above, modname .. ":debug_object")
		-- local pos = pointed_thing.under
		-- local node = minetest.get_node(pos)
		-- node.param2 = node.param2 + 1
		-- minetest.set_node(pos, node)
	end,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.under then
			local pos = pointed_thing.under
			local node = minetest.get_node(pos)
			node.param2 = node.param2 - 1
			minetest.set_node(pos, node)
		end
	end,
})

minetest.register_lbm({
	name = "cicrev:debug",
	nodenames = {"cicrev:test_node_2"},
	run_at_every_load = true,
    action = function(pos, node)
		minetest.chat_send_all("Found testnode at: " .. minetest.pos_to_string(pos))
	end,
})

minetest.register_craftitem("cicrev:time_wand", {
	description = "Wand of time",
	inventory_image = "cicrev_time_wand.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		local pos = pointed_thing.above
		local timer = minetest.get_node_timer(pos)
		timer:set(1, 0)
	end,
	on_use = function(itemstack, user, pointed_thing)
		minetest.chat_send_all("Setting time to morining.")
		minetest.set_timeofday(0.25)
	end,
})


minetest.register_node("cicrev:test_node_1", {
	description = "test_node_1",
	tiles = {"test_node_1.png"},
	groups = {test = 1},
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		local meta = minetest.get_meta(pos)

		timer:start(1)
		meta:set_int("n", 1)
		meta:set_int("time", minetest.get_gametime())
	end,
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local n = meta:get_int("n")
		local time = meta:get_int("time")

		meta:set_int("n", n + 1)
		meta:set_int("time", minetest.get_gametime())

		minetest.chat_send_all("" .. n)
		-- minetest.chat_send_all("Time since last call: " .. minetest.get_gametime() - time)
		return true
	end,


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
