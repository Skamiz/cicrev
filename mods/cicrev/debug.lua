--[[
	A place for deving new code bofore deciding what to do with it.
]]


local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local worldpath = minetest.get_worldpath()
local storage = minetest.get_mod_storage()



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
	"background[0,0;10.25,5.25;player_inv_bg.png;true]",
	-- "background[-0.05,-0.05;10.25,5.25;player_inv_bg.png;true]",
	-- "listcolors[#837347;#a9986a;#cebc8c]",
	-- "listcolors[#837347;#a9986a;#020202]",
	-- "listcolors[#837347;#a9986a]",
	"list[current_player;main;0.25,0.25;8,4;]",
}

minetest.register_chatcommand("debug", {
	params = "",
	description = "Just another way to execute debug code.",
	privs = {server=true},
	func = function(name, param)
		param = param:split(" ")
		-- for k, v in pairs(param) do
		-- 	minetest.chat_send_all(v)
		-- end
	end,
})

minetest.register_entity("cicrev:test_mob", {
	initial_properties = {
		visual = "mesh",
		mesh = "minetest_mob_test.b3d",
		textures = {"minetest_mob_test.png"},
		static_save = false,
		-- visual_size = {x = 1, y = 1, z = 1},
	},

    on_activate = function(self, staticdata)
      self.object:set_animation({x=1, y=60}, 20, 0, true)
    end,
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		minetest.chat_send_all("punched!")
		self.object:set_animation({x=1, y=60}, 20, 0, false)
		-- self.object:remove()
	end,
})

fs = table.concat(fs)
test_fs = table.concat(test_fs)

local function print_table(po)
	for k, v in pairs(po) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
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

	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		player_effects.add_effect(user, {
			source = "debuging_axe",
			effect_name = "speed",
			-- influence = function(speed) return speed*2 end,
			text_influence = "function(speed) return speed*2 end",
			priority = 5,
			persistant = true,
		})
	end,
	on_use = function(itemstack, user, pointed_thing)
		player_effects.remove_effect(user,"speed", "debuging_axe")

		-- local node = minetest.get_node(pointed_thing.under)
		-- node.param2 = y_rot[node.param2]
		-- minetest.set_node(pointed_thing.under, node)
	end,
})

minetest.register_lbm({
	name = "cicrev:debug",
	nodenames = {"cicrev:test_node_3"},
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
		local pos = pointed_thing.under
		local timer = minetest.get_node_timer(pos)
		timer:set(1, 0)
	end,
	on_use = function(itemstack, user, pointed_thing)
		minetest.chat_send_all("Setting time to morining.")
		minetest.set_timeofday(0.25)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		minetest.chat_send_all("Setting time to midnight.")
		minetest.set_timeofday(0)
	end
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
