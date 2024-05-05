--[[
	A place for deving new code bofore deciding what to do with it.
]]


local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()
local storage = minetest.get_mod_storage()

local switch = true


local fs = {
	"formspec_version[4]",
	"size[10.75,11,<fixed_size>]",
	-- "background9[0,0;10.75,11;bckg.png;<auto_clip>;8]",
	"container[0.5,0.5]",
	"container[3.75,0]",
	"list[current_player;craft;0,0;3,3;]",
	"list[current_player;craftpreview;5,1.25;1,1;]",
	"list[current_player;craftresult;5,0;1,1;]",
	"container_end[]",
	"container[0,5.25]",
	"background[-0.25,-0.25;10.25,5.25;player_inv_bg.png;<auto_clip>]",
	"listcolors[#837347;<slot_bg_hover>;<slot_border>]",
	"list[current_player;main;0,0;8,4;]",
	"container_end[]",
	"container_end[]",
}

local test_fs = {
	"formspec_version[4]",
	"size[10.25,5.25,<fixed_size>]",
	"image[5,0;1,1;[combine:32x32:0,0=fc_reload.png]",
	"image[0,0;1,1;fc_reload.png]",
	-- "background[0,0;10.25,5.25;player_inv_bg.png;true]",
	-- "background[-0.05,-0.05;10.25,5.25;player_inv_bg.png;true]",
	-- "listcolors[#837347;#a9986a;#cebc8c]",
	-- "listcolors[#837347;#a9986a;#020202]",
	-- "listcolors[#837347;#a9986a]",
	-- "list[current_player;main;0.25,0.25;8,4;]",
}
fs = table.concat(fs)
test_fs = table.concat(test_fs)

minetest.register_chatcommand("debug", {
	params = "",
	description = "Just another way to execute debug code.",
	privs = {server=true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)

		minetest.show_formspec(player:get_player_name(), "test", test_fs)

		-- param = param:split(" ")
		-- for k, v in pairs(param) do
		-- 	minetest.chat_send_all(v)
		-- end
		-- player:hud_set_hotbar_itemcount(param)
		-- player:hud_set_hotbar_image(cicrev.get_hotbar_image("cicrev_hotbar.png", param))
		-- player:hud_set_hotbar_selected_image("cicrev_glass.png")
		-- player:set_hp(param, "debug command")
	end,
})

minetest.register_entity("cicrev:test_mob", {
	initial_properties = {
		visual = "mesh",
		mesh = "gyro.b3d",
		textures = {"debug.png"},
		static_save = false,
		visual_size = {x = 5, y = 5, z = 5},
	},

    on_activate = function(self, staticdata)
		minetest.chat_send_all("activated")
      -- self.object:set_animation({x=1, y=60}, 20, 0, true)
	  self.object:set_bone_position("large", {x=1, y=1, z=0}, {x=1, y=1, z=0})
    end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		minetest.chat_send_all("punched!")
		-- self.object:set_animation({x=1, y=60}, 20, 0, false)
		-- self.object:remove()
		self.object:set_bone_position("foo", {x=0, y=1, z=0}, {x=1, y=0, z=0})
	end,
})





local function print_table(po)
	for k, v in pairs(po) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end


local abm_detect

local function f(i) return i * i end

local function hi()
	print("hi")
end
local function run_async()
	local np_terrain = {
		offset = 0,
		scale = 1,
		spread = {x = 1944, y = 3078, z = 1944},
		seed = 110013,
		octaves = 5,
		persist = 0.3,
		lacunarity = 3,
		--flags = 'noeased',
	}
	local nobj_terrain = minetest.get_perlin(np_terrain)

	minetest.handle_async(function(a_nobj_terrain)

		return a_nobj_terrain:get_2d({x = 100, y = 100})
	end,
	function(val)
		print("returned val: " .. val)
	end,
	nobj_terrain)

	print("actual val: " .. nobj_terrain:get_2d({x = 100,y  = 100}))

	-- print("outside async:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")


end

local buffer = {}
local function run_noise_speed_test()
	local np = {
		offset = 3,
		scale = 10,
		spread = {x = 100, y = 30, z = 40},
		seed = 30,
		octaves = 5,
		persist = 0.6,
		lacunarity = 2.3,
		flags = "eased",
	}
	local chunk_size = vector.new(80, 80, 80)
	local noise_obj = minetest.get_perlin(np, chunk_size)
	local noise_map_obj = minetest.get_perlin_map(np, chunk_size)

	local positions = {}
	for x = 1, 80 do
		for y = 1, 80 do
			for z = 1, 80 do
				-- table.insert(positions, vector.new(x, y, z))
				table.insert(positions, vector.new(math.random(-5000, 5000), math.random(-5000, 5000), math.random(-5000, 5000)))
			end
		end
	end

	local t0 = minetest.get_us_time()
	for k, pos in pairs(positions) do
		-- noise_obj:get_2d(pos)
		noise_obj:get_3d(pos)
	end
	print("single noise:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")

	local t0 = minetest.get_us_time()
	for i = 1, 80 do
		noise_map_obj:get_2d_map_flat(positions[i], buffer)
	end
	print("2d noise:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")

	local t0 = minetest.get_us_time()
	noise_map_obj:get_3d_map_flat(positions[1], buffer)
	print("3d noise:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")
end

local function run_speed_speed_test()
	local t0 = minetest.get_us_time()
	for i = 1, 80*80*4 do
		minetest.get_us_time()
	end
	print("get_time:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")
end

local function add(a, b)
	return a + b
end

local function run_function_speed_test()
	-- conclusion: not mesured diference
	local t0 = minetest.get_us_time()
	for i = 1, 80*80*80 do
		local result = i + (i + 1)
	end
	print("direct:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")

	local t0 = minetest.get_us_time()
	for i = 1, 80*80*80 do
		local result = add(i, i + 1)
	end
	print("function:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")
	print(result)
end

local max = math.max
local function run_localization_speed_test()
	-- conclusion: no mesured diference
	local t0 = minetest.get_us_time()
	for i = 1, 80*80*80000 do
		local result = math.max(i, (i + 1))
	end
	print("math.max:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")

	local t0 = minetest.get_us_time()
	for i = 1, 80*80*80000 do
		local result = max(i, i + 1)
	end
	print("local max:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")
end

local function run_loop_speed_test()
	-- conclusion: no mesured diference

	local t0 = minetest.get_us_time()
	for i = 1, 80*80*80000 do

	end
	print("loop speed:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")

	local t = true
	local t0 = minetest.get_us_time()
	for i = 1, 80*80*80000 do
		if t then end
	end
	print("if loop speed:  " .. (minetest.get_us_time() - t0) / 1000 .. " ms")
end



minetest.register_craftitem("cicrev:axe_of_debug", {
	description = "axe of debug",
	inventory_image = "cicrev_axe_of_trees.png",
	wield_image = "cicrev_axe_of_trees.png",
	stack_max = 1,
	tool_capabilities = {
		groupcaps = {
			test = {maxlevel=0, uses=20, times={[1]=1, [2]=2, [3]=1, [4]=4}},
		},
	},
	on_place = function(itemstack, placer, pointed_thing)

		-- minetest.show_formspec(placer:get_player_name(), "test", test_fs)
		-- place_nodebox_object(pointed_thing.under, minetest.get_node(pointed_thing.under))

		-- run_noise_speed_test()
		-- run_speed_speed_test()
		-- run_function_speed_test()
		-- run_localization_speed_test()
		-- run_loop_speed_test()

		-- run_async()

		-- local np_terrain = {
		-- 	offset = 0,
		-- 	scale = 1,
		-- 	spread = {x = 1944, y = 3078, z = 1944},
		-- 	seed = 110013,
		-- 	octaves = 5,
		-- 	persist = 0.3,
		-- 	lacunarity = 3,
		-- 	--flags = 'noeased',
		-- }
		-- local no = minetest.get_perlin(np_terrain)
		-- local t0 = minetest.get_us_time()
		-- for x = 1, 600 do
		-- 	for z = 1, 600 do
		-- 		no:get_2d({x = x * 100,y = z * 100})
		-- 		no:get_2d({x = x * 100 + 50,y = z * 100 + 50})
		-- 	end
		-- end
		-- print(" perlin time: " .. (minetest.get_us_time() - t0) / 1000000 .. " s")
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)

		-- player_effects.add_effect(user, {
		-- 	source = "debuging_axe",
		-- 	effect_name = "speed",
		-- 	-- influence = function(speed) return speed*2 end,
		-- 	text_influence = "function(speed) return speed*2 end",
		-- 	priority = 5,
		-- 	persistant = true,
		-- })
	end,
	on_use = function(itemstack, user, pointed_thing)
		-- abm_detect = true
		player_effects.remove_effect(user,"speed", "debuging_axe")

		--
		-- local node = minetest.get_node(pointed_thing.under)
		-- node.param2 = y_rot[node.param2]
		-- minetest.set_node(pointed_thing.under, node)
	end,
})

-- minetest.register_abm({
--     label = "Active Block Detection",
--     nodenames = {"air"},
--     interval = 10,
--     chance = 1,
--     action = function(pos, node, active_object_count, active_object_count_wider)
-- 		-- if not abm_detect then return end
-- 		minetest.set_node(pos, {name = "cicrev:glass"})
--         minetest.after(5,
-- 			function()
-- 				abm_detect = false
-- 			end
-- 		)
--     end,
-- })

-- minetest.register_lbm({
-- 	name = "cicrev:debug_lbm",
-- 	nodenames = {"cicrev:test_node_3", "cicrev:test_node_4"},
-- 	run_at_every_load = true,
--     action = function(pos, node)
-- 		minetest.chat_send_all("lmb tick")
-- 		if switch then
-- 			node.name = "cicrev:test_node_4"
-- 			minetest.set_node(pos, node)
-- 		else
-- 			node.name = "cicrev:test_node_3"
-- 			minetest.set_node(pos, node)
-- 		end
-- 	end,
-- })


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

		-- minetest.chat_send_all("Timer tick: " .. n)
		-- minetest.chat_send_all("Time since last call: " .. minetest.get_gametime() - time)
		return true
	end,
})
-- minetest.register_abm({
--     label = "abm detection",
--     nodenames = {"cicrev:test_node_1"},
--     interval = 1,
--     chance = 1,
--     action = function(pos, node, active_object_count, active_object_count_wider)
-- 		minetest.chat_send_all("ABM tick: ")
--     end,
-- })
minetest.register_node("cicrev:test_node_2", {
	description = "test_node_2",
	tiles = {"test_node_2.png"},
	groups = {test = 2, hand = 1,},
	on_punch = function(pos, node, player, pointed_thing)
		local n_meta = minetest.get_meta(pos)
		n_meta:set_string("fall_tree_cap2",minetest.serialize(pointed_thing))
	end,
	on_dig = function(pos, node, digger)
		-- calculation of eye position ripped from builtins 'pointed_thing_to_face_pos'
		local digger_pos = digger:get_pos()
		local eye_height = digger:get_properties().eye_height
		local eye_offset = digger:get_eye_offset()
		digger_pos.y = digger_pos.y + eye_height
		digger_pos = vector.add(digger_pos, eye_offset)

		-- determine ray end position
		local look_dir = digger:get_look_dir()
		look_dir = vector.multiply(look_dir, 5) -- replace 5 with tool range
		local end_pos = vector.add(look_dir, digger_pos)

		-- get pointed_thing
		local ray = minetest.raycast(digger_pos, end_pos, false, false)
		local ray_pt = ray:next()

		local finepos = minetest.pointed_thing_to_face_pos(digger,ray_pt)
		local finepos2 = ray_pt.intersection_point
		-- alternatively if you only care about face direction
		local normal = ray_pt.intersection_normal

		minetest.debug("ray_pt: \n"..dump(finepos))
		minetest.debug("ray_intersection: \n"..dump(finepos2))
		minetest.debug("face_normal: \n"..dump(normal))
	end,
})
local eight = 12
minetest.register_node("cicrev:test_node_3", {
	description = "test_node_3",
	drawtype = "nodebox",
	tiles = {"test_node_3.png"},
	groups = {test = 3},
	node_box = {
		type = "fixed",
		-- fixed = {
		-- 	{-eight/16, -eight/16, -eight/16, 0/16, 0/16, 0/16},
		-- 	{-eight/16, -0/16, -eight/16, 0/16, eight/16, 0/16},
		-- 	{-0/16, -eight/16, -eight/16, eight/16, 0/16, 0/16},
		-- 	{-0/16, -0/16, -eight/16, eight/16, eight/16, 0/16},
		-- 	{-eight/16, -eight/16, -0/16, 0/16, 0/16, eight/16},
		-- 	{-eight/16, -0/16, -0/16, 0/16, eight/16, eight/16},
		-- 	{-0/16, -eight/16, -0/16, eight/16, 0/16, eight/16},
		-- 	{-0/16, -0/16, -0/16, eight/16, eight/16, eight/16},
		-- },
		fixed = {
			{-8/16, -8/16, -8/16, -3/16, -3/16, -3/16},
			{-3/16, -8/16, -8/16,  3/16, -3/16, -3/16},
			{ 3/16, -8/16, -8/16,  8/16, -3/16, -3/16},

			{-8/16, -8/16, -3/16, -3/16, -3/16,  3/16},
			{-3/16, -8/16, -3/16,  3/16, -3/16,  3/16},
			{ 3/16, -8/16, -3/16,  8/16, -3/16,  3/16},

			{-8/16, -8/16,  3/16, -3/16, -3/16,  8/16},
			{-3/16, -8/16,  3/16,  3/16, -3/16,  8/16},
			{ 3/16, -8/16,  3/16,  8/16, -3/16,  8/16},

			{-8/16, -3/16, -8/16, -3/16,  3/16, -3/16},
			{-3/16, -3/16, -8/16,  3/16,  3/16, -3/16},
			{ 3/16, -3/16, -8/16,  8/16,  3/16, -3/16},

			{-8/16, -3/16, -3/16, -3/16,  3/16,  3/16},
			{-3/16, -3/16, -3/16,  3/16,  3/16,  3/16},
			{ 3/16, -3/16, -3/16,  8/16,  3/16,  3/16},

			{-8/16, -3/16,  3/16, -3/16,  3/16,  8/16},
			{-3/16, -3/16,  3/16,  3/16,  3/16,  8/16},
			{ 3/16, -3/16,  3/16,  8/16,  3/16,  8/16},

			{-8/16,  3/16, -8/16, -3/16,  8/16, -3/16},
			{-3/16,  3/16, -8/16,  3/16,  8/16, -3/16},
			{ 3/16,  3/16, -8/16,  8/16,  8/16, -3/16},

			{-8/16,  3/16, -3/16, -3/16,  8/16,  3/16},
			{-3/16,  3/16, -3/16,  3/16,  8/16,  3/16},
			{ 3/16,  3/16, -3/16,  8/16,  8/16,  3/16},

			{-8/16,  3/16,  3/16, -3/16,  8/16,  8/16},
			{-3/16,  3/16,  3/16,  3/16,  8/16,  8/16},
			{ 3/16,  3/16,  3/16,  8/16,  8/16,  8/16},
		},
	},
	-- can_dig = function(pos, player)
	-- 	return pos.x%2 == 0
	-- end,
})
minetest.register_node("cicrev:test_node_4", {
	description = "test_node_4",
	tiles = {"test_node_4.png"},
	groups = {test = 4},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local meta = minetest.get_meta(pos)
		minetest.chat_send_all(meta:get_string("foo"))
	end,
	on_punch = function(pos, node, puncher, pointed_thing)
		local meta = minetest.get_meta(pos)
		minetest.chat_send_all(meta:get_string("foo"))
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("foo", "bar")
	end,
})
minetest.register_node("cicrev:mesh_node", {
	description = "mesh node",
	drawtype = "mesh",
	mesh = "debug.obj",
	tiles = {"debug.png"},
	-- groups = {test = 4},
	paramtype = "light",
})


minetest.register_node("cicrev:grass_sand", {
	description = "Grass-Sand",
	tiles = {"test_grass_sand_1.png", "test_grass_sand_2.png", "test_grass_sand_3.png", "test_grass_sand_4.png", "test_grass_sand_5.png", "test_grass_sand_6.png"},
	paramtype2 = "facedir",
})
minetest.register_node("cicrev:sand_patch", {
	description = "Sand Patch",
	drawtype = "nodebox",
	visual_scale = 2,
	paramtype = "light",
	tiles = {"test_sand_patch.png", "cicrev_sand.png"},
	use_texture_alpha = "blend",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
			{-0.5, 0.25 + 0.001, -0.5, 0.5, 0.25 + 0.001, 0.5},
		},
	},
	collision_box = {type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},},
	selection_box = {type = "regular"},
})

minetest.register_node("cicrev:variant_textures", {
	description = "test",
	tiles = {
		{name = "cicrev_var_A.png", align_style = "world", scale = 2},
		{name = "cicrev_var_B.png", align_style = "world", scale = 2},
		{name = "cicrev_var_C.png", align_style = "world", scale = 2},
		{name = "cicrev_var_D.png", align_style = "world", scale = 2},
		{name = "cicrev_var_E.png", align_style = "world", scale = 2},
		{name = "cicrev_var_F.png", align_style = "world", scale = 2},
	},
	paramtype2 = "facedir",
})

-- local orig_get = sfinv.pages["sfinv:crafting"].get
-- sfinv.override_page("sfinv:crafting", {
--     get = function(self, player, context)
--         local fs = orig_get(self, player, context)
--         return fs .. "background[-0.1875,-0.2603;8.4,9.8378;cicrev_craft_background.png;false]"
-- 		.. "listcolors[#777777;#929292]"
--     end
-- })


minetest.register_node("cicrev:brick_mold", {
	description = "Brick Mold",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"cicrev_planks_chestnut.png"},
	-- groups = {oddly_breakable_by_hand = 3},
	node_box = {
		type = "fixed",
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.5, 0.5, -2/16, -7/16},
			{-0.5, -0.5, 7/16, 0.5, -2/16, 8/16},
			{-0.5, -0.5, -1/16, 0.5, -2/16, 1/16},
			{-8/16, -8/16, -8/16, -7/16, -2/16, 8/16},
			{-1/16, -8/16, -8/16, 1/16, -2/16, 8/16},
			{7/16, -8/16, -8/16, 8/16, -2/16, 8/16},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {{-8/16, -8/16, -8/16, 8/16, -2/16, 8/16}},
	},
	collision_box = {
		type = "fixed",
		fixed = {{-8/16, -8/16, -8/16, 8/16, -2/16, 8/16}},
	},
})
minetest.register_node("cicrev:brick_mold_full", {
	description = "Full Brick Mold",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"cicrev_frame_wet.png", "cicrev_frame_wet.png", "cicrev_planks_chestnut.png"},
	-- groups = {oddly_breakable_by_hand = 3},
	drop = "cicrev:brick_mold",
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		minetest.set_node(pos, {name = "cicrev:bricks_unfired"})
	end,
	node_box = {
		type = "fixed",
		fixed = {{-8/16, -8/16, -8/16, 8/16, -2/16, 8/16},}
	},
})
minetest.register_node("cicrev:bricks_unfired", {
	description = "Unfired Bricks",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"cicrev_bricks_wet.png"},
	-- groups = {oddly_breakable_by_hand = 3},
	drop = "cicrev:clay_lump",
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16, -1/16, -2/16, -1/16},
			{1/16, -8/16, -7/16, 7/16, -2/16, -1/16},
			{-7/16, -8/16, 1/16, -1/16, -2/16, 7/16},
			{1/16, -8/16, 1/16, 7/16, -2/16, 7/16},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {{-7/16, -7/16, -8/16, 7/16, -2/16, 7/16}},
	},
	on_construct = function(pos)
		local t = minetest.get_node_timer(pos)
		t:start(60*5)
	end,
	on_timer = function(pos, elapsed)
		minetest.set_node(pos, {name = "cicrev:bricks_dry"})
	end,
})
minetest.register_node("cicrev:bricks_dry", {
	description = "Dry Bricks",
	drawtype = "nodebox",
	paramtype = "light",
	tiles = {"cicrev_bricks_dry.png"},
	-- groups = {oddly_breakable_by_hand = 2},
	drop = "cicrev:brick 4",
	node_box = {
		type = "fixed",
		fixed = {
			{-7/16, -8/16, -7/16, -1/16, -2/16, -1/16},
			{1/16, -8/16, -7/16, 7/16, -2/16, -1/16},
			{-7/16, -8/16, 1/16, -1/16, -2/16, 7/16},
			{1/16, -8/16, 1/16, 7/16, -2/16, 7/16},
		}
	},
	collision_box = {
		type = "fixed",
		fixed = {{-7/16, -7/16, -8/16, 7/16, -2/16, 7/16}},
	},
})

minetest.register_node("cicrev:tank", {
	description = "Glass Tank",
	drawtype = "glasslike_framed",
	tiles = {"cicrev_glass.png", "cicrev_glass.png", "cicrev_bricks_dry.png", "cicrev_bricks_dry.png", "cicrev_bricks_dry.png", "cicrev_bricks_dry.png"},
	-- overlay_tiles = {"", "cicrev_bricks_dry.png"},
	special_tiles = {"cicrev_bricks_dry.png"},
	use_texture_alpha = "blend",
	paramtype = "light",
	paramtype2 = "glasslikeliquidlevel",
	sunlight_propagates = true,
	groups = {hand = 2},
})


local all_items = {}
for k, _ in pairs(minetest.registered_items) do
	all_items[#all_items + 1] = k
end
for i = 1, 50 do
	fast_craft.register_craft({
		output = {all_items[math.random(#all_items)], math.random(5)},
		input = {
			["cicrev:thatch"] = math.ceil(i/10),
		},
	})
end
