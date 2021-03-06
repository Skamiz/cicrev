--[[
	A place for deving new code bofore deciding what to do with it.
]]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()
local storage = minetest.get_mod_storage()

local function place_slice(pos)
	for i = 0, 2 do
		for j = 0, 2 do
			minetest.set_node({x = pos.x + i, y = pos.y, z = pos.z + j}, {name = "df_stones:slate"})
		end
	end
end

local function place_tile(pos, tile_type)
	if tile_type == "wall" then
		for i = 0, 4 do
			place_slice({x = pos.x, y = pos.y + i, z = pos.z})
		end
	elseif tile_type == "coridor" then
		place_slice(pos)
		place_slice({x = pos.x, y = pos.y + 4, z = pos.z})
	end
end


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
		storage:set_string("foo", "bar")
		-- local pos = placer:get_pos()
		-- pos = vector.round(pos)
		-- place_tile({x = pos.x - 1, y = pos.y - 5, z = pos.z - 1}, "wall")
	end,
	on_use = function(itemstack, user, pointed_thing)
		minetest.chat_send_all(storage:get_string("foo"))
		minetest.chat_send_all(type(minetest.get_inventory({type = "detached", name = "pull_cart:cart_fdg"})))
		-- local pos = user:get_pos()
		-- pos = vector.round(pos)
		-- place_tile({x = pos.x - 1, y = pos.y - 5, z = pos.z - 1}, "coridor")
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
