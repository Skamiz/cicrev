local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local storage = minetest.get_mod_storage()

-- dofile(modpath .. "/other_file.lua")

--[[
test if leaving the game while pulling a cart crashes the server
unify 'modname ..'

stretch goals
--]]

local pull_cart = {}
pull_cart.cart_number = tonumber(storage:get("cart_number") or 1)
pull_cart.players = {}

local speed_multiplier = 0.7
local cart_inv_size = 2*8

local function update_cart_apparence(cart)
	for _, child in pairs(cart.object:get_children()) do
		child:remove()
	end
	local item_name = cart.inv:get_stack("main", 1):get_name()
	if item_name ~= "" then
		-- minetest.chat_send_all("-> " .. item:get_name())
		local content = minetest.add_entity(cart.object:get_pos(), modname .. ":pull_cart_content")
		content:set_attach(cart.object, "", {x=0, y = 15, z=0})
		content:set_properties({wield_item = item_name})
	end
end

local function get_callbacks(cart)
	return {
		on_move = function(inv, from_list, from_index, to_list, to_index, count, player)
			update_cart_apparence(cart)
		end,
	    on_put = function(inv, listname, index, stack, player)
			update_cart_apparence(cart)
		end,
	    on_take = function(inv, listname, index, stack, player)
			update_cart_apparence(cart)
		end,
	}
end
local function distance_2(v)
	return v.x*v.x + v.y*v.y + v.z*v.z
end

minetest.register_craftitem(modname .. ":pull_cart_spawner", {
	description = "Cart Spawner",
	inventory_image = "pull_cart_planks.png",
	on_place = function(itemstack, placer, pointed_thing)
		local cart = minetest.add_entity(pointed_thing.above, modname .. ":pull_cart")
		local rot = cart:get_rotation()
		rot.y = minetest.dir_to_yaw(vector.subtract(placer:get_pos(), cart:get_pos()))
		cart:set_rotation(rot)
		-- todo: decrease item count
	end,
})

minetest.register_node(modname .. ":pull_cart", {
	description = "Cart",
	tiles = {"pull_cart_planks.png"},
	-- inventory_image = "insert_nice_image_here.png",
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-10/16, -2/16, -10/16, 10/16, 0/16, 12/16},

			{-10/16, 0/16, -10/16, -8/16, 8/16, -8/16},
			{8/16, 0/16, -10/16, 10/16, 8/16, -8/16},
			{-10/16, 0/16, 10/16, -8/16, 4/16, 12/16},
			{8/16, 0/16, 10/16, 10/16, 4/16, 12/16},

			{-8/16, 4/16, -10/16, 8/16, 8/16, -8/16},
			{-10/16, 4/16, -8/16, -8/16, 8/16, 24/16},
			{8/16, 4/16, -8/16, 10/16, 8/16, 24/16},

			{-10/16, -4/16, -1/16, 10/16, -2/16, 1/16},

			{10/16, -6/16, -5/16, 12/16, 0/16, 5/16},
			{10/16, -8/16, -3/16, 12/16, 2/16, 3/16},

			{-12/16, -6/16, -5/16, -10/16, 0/16, 5/16},
			{-12/16, -8/16, -3/16, -10/16, 2/16, 3/16},

		},

	},
	groups = {hand = 1},
	-- insert on_place here,
})


local function show_cart_formspec(player, cart)
	minetest.show_formspec(player:get_player_name(), "pull_cart:inventory",
		"formspec_version[4]" ..
		"size[10.75,8.5]"..
		"container[0.5,0.5]"..
		"list[detached:pull_cart:cart_" .. cart.cart_number .. ";main;0,0;8,2;]" ..
		"list[current_player;main;0,2.75;8,4;]" ..
		"listring[]" ..
		"container_end[]" ..
		""
	)
end

local function destroy_cart(cart)
	local inv_content = cart.inv:get_list("main")
	local pos = cart.object:get_pos()

	for _, item in pairs(inv_content) do
		minetest.add_item(pos, item)
	end
	-- todo: return cart item
	storage:set_string("cart_" .. cart.cart_number, "")
	cart.object:remove()
end

minetest.register_entity(modname .. ":pull_cart", {
	initial_properties = {
		visual = "item",
		visual_size = {x = 2/3, y = 2/3, z = 2/3},
		physical = true,
		collide_with_objects = true,
		static_save = true,
		wield_item = modname .. ":pull_cart",
	},

	_attach = function(self, player)
		self.puller = player
		local player_name = player:get_player_name()
		if pull_cart.players[player_name] then
			pull_cart.players[player_name]:_detach()
		end
		pull_cart.players[player_name] = self

		-- TODO:naturally this shouldn't touch the PO so directly
		local po = player:get_physics_override()
		po.speed = speed_multiplier
		po.jump = 0
		player:set_physics_override(po)
	end,

	_detach = function(self, player)
		self.puller = nil
		local player_name = player:get_player_name()
		pull_cart.players[player_name] = nil

		local rot = self.object:get_rotation()
		rot.x = -(math.pi / 8)
		self.object:set_rotation(rot)

		local po = player:get_physics_override()
		po.speed = 1
		po.jump = 1
		player:set_physics_override(po)
	end,

	on_rightclick = function(self, clicker)
		if clicker:get_player_control().sneak then
			if self.puller then
				self:_detach(clicker)
			else
				self:_attach(clicker)
			end
		else
			show_cart_formspec(clicker, self)
		end
	end,

	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		destroy_cart(self)
	end,

	get_staticdata = function(self)
		return tostring(self.cart_number)
	end,

	on_activate = function(self, staticdata, dtime_s)
		self.puller = nil
		self.object:set_acceleration({x=0, y=-9.81, z=0})

		local rot = self.object:get_rotation()
		rot.x = -(math.pi / 8)
		self.object:set_rotation(rot)

		if staticdata == "" then
			self.cart_number = pull_cart.cart_number
			pull_cart.cart_number = pull_cart.cart_number + 1
			storage:set_int("cart_number", pull_cart.cart_number)

			local inv = minetest.create_detached_inventory("pull_cart:cart_" .. self.cart_number, get_callbacks(self))
			inv:set_size("main", cart_inv_size)

			self.inv = inv
		else
			self.cart_number = tonumber(staticdata)
			local inv = minetest.get_inventory({type = "detached", name = "pull_cart:cart_" .. self.cart_number})
			if not inv then
				inv = minetest.create_detached_inventory("pull_cart:cart_" .. self.cart_number, get_callbacks(self))
				inv:set_size("main", cart_inv_size)
				local inv_content = minetest.deserialize(storage:get_string("cart_" .. self.cart_number))
				inv:set_list("main", inv_content)
			end

			self.inv = inv
		end

		update_cart_apparence(self)
	end,

	on_deactivate = function(self)
		local inv_content = self.inv:get_list("main")
		for k, v in pairs(inv_content) do
			inv_content[k] = v:to_string()
		end

		local inv_content = minetest.serialize(inv_content)
		storage:set_string("cart_" .. self.cart_number, inv_content)
	end,

	on_step = function(self, dtime, moveresult)
		if self.puller then

			local puller = self.puller
			local object = self.object
			local p_pos = puller:get_pos()
			p_pos.y = p_pos.y + 0.5
			local direction = vector.subtract(p_pos, object:get_pos())

			if distance_2(direction) > (2.5*2.5) then
				self:_detach()
				return
			end

			local rot = object:get_rotation()
			rot.x = math.atan2(direction.y, math.abs(direction.z)) / 2
			rot.y = minetest.dir_to_yaw(direction)
			object:set_rotation(rot)

			direction.y = 0
			local direction = vector.normalize(direction)
			local o_pos = object:get_pos()
			local pos = vector.subtract(p_pos, vector.multiply(direction, 1.2))
			pos.y = o_pos.y
			if minetest.registered_nodes[minetest.get_node(vector.round(pos)).name].walkable then
				pos.y = pos.y + 0.6
			end
			object:move_to(pos)
		end
	end,
})

minetest.register_entity(modname .. ":pull_cart_content", {
	initial_properties = {
		visual = "item",
		visual_size = {x = 2, y = 2, z = 2},
		physical = true,
		-- collide_with_objects = true,
		static_save = false,
		-- wield_item = modname .. ":pull_cart",
		pointable = false,
	},
})
