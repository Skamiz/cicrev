--[[
respawn anchor - node at which you can set your spawn point, for a price
	- when mined (only valid tool is hand) moves one node in the direction it is being punched
		- tool doesn't have to be hand necesarily, but it must always be a constant time, regardless of tech level, that is realtively slow, so it isn't too easy to cary them away
		- can be pushed up slopes
		- can be pushed into any node that is buildable_to
	- gravity afected
		- make sure it is never ever droped as an item
	- spawns randomly in the world
	configuration options:
		- price for setting your respawn point - consider this further
			- just specifying a single item seems like it's too unflexible
			- maybe in code have a condition function for wether it respawn can be set
			  and the settings menu is just a simple override for non-modders
		- how often you can respawn at the given anchor
			- negative/zero for infinite respawns
	spawn some particles on binding to an anchor
]]

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
-- dofile(modpath .. "/foo.lua")

local respawn_anchor = {}

-- detect "air" equivalent nodes
-- minetest.register_on_mods_loaded(function()
-- 	for name, def in pairs(minetest.registered_nodes) do
-- 		local groups = table.copy(def.groups)
--
-- 		if def.drawtype == "airlike" and def.walkable == false and def.pointable == false and def.buildable_to == true then
-- 			groups["air"] = 1
-- 			minetest.override_item(name, {
-- 				groups = groups,
-- 			})
-- 		end
-- 	end
-- end)

local respawn_range = 3
local function find_suitable_spawn_positions(middle)
	minetest.load_area(middle) -- make sure that the searched area isn't just 'ignore' nodes

	local positions = {}
	for x = middle.x - respawn_range, middle.x + respawn_range do
		for z = middle.z - respawn_range, middle.z + respawn_range do
			local a, b, c
			for y = middle.y + respawn_range, middle.y - respawn_range, -1 do
				b, c = a, b
				local pos = vector.new(x, y, z)
				a = minetest.registered_nodes[minetest.get_node(pos).name].walkable
				if a == true and b == false and c == false then
					positions[#positions + 1] = pos
				end
			end
		end
	end
	return positions
end

local function set_respawn_pos(player, pos)
	local meta = player:get_meta()
	meta:set_string("respawn_pos", minetest.pos_to_string(pos))
end
local function respawn_player(player)
	local meta = player:get_meta()
	local pos = meta:get("respawn_pos")
	if not pos then return false end

	pos = minetest.string_to_pos(pos)

	local pp = find_suitable_spawn_positions(pos)

	local fpos = pp[math.random(#pp)]
	-- local fpos = find_spawn_place(pos)
	if not fpos then return false end
	fpos.y = fpos.y + 0.5
	player:set_pos(fpos)

	return true
end

local function spawn_particles(pos)
	minetest.add_particlespawner({
		amount = 12,
		time = 1,
		minpos = {x = pos.x - 4/16, y = pos.y - 0.5, z = pos.z - 4/16},
        maxpos = {x = pos.x + 4/16, y = pos.y + 0.5, z = pos.z + 4/16},
        minvel = {x=0, y=0.5, z=0},
        maxvel = {x=0, y=1, z=0},
        minexptime = 1,
        maxexptime = 1.5,
        minsize = 1,
        maxsize = 1,
		collisiondetection = false,
		texture = "respawn_anchor_particle.png",
	})
end

minetest.register_node(modname .. ":pillar", {
	description = "Respawn Anchor",
	drawtype = "nodebox",
	tiles = {
		"respawn_anchor_top.png",
		"respawn_anchor_bottom.png",
		"respawn_anchor_side.png",
	},
	groups = {falling_node = 4, hand = 3, oddly_breakable_by_hand = 1},
	paramtype = "light",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16,  0/16,  8/16},
			{-6/16,  -1/16, -6/16,  6/16,  8/16,  6/16},
			{-8/16,  2/16, -8/16,  8/16,  6/16,  8/16},
		},
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		set_respawn_pos(clicker, pos)
		spawn_particles(pos)
		-- respawn_player(clicker)
	end,
	on_dig = function(pos, node, digger)
		if minetest.is_creative_enabled(digger:get_player_name()) then
			minetest.remove_node(pos)
			minetest.handle_node_drops(pos, {modname .. ":pillar"}, digger)
			return true
		end
		local new_pos = pos + minetest.yaw_to_dir(digger:get_look_horizontal())
		if minetest.registered_nodes[minetest.get_node(new_pos).name].buildable_to then
			minetest.remove_node(pos)
			minetest.set_node(new_pos, node)
			minetest.check_for_falling(new_pos)
		else
			new_pos.y = new_pos.y + 1
			if minetest.registered_nodes[minetest.get_node(new_pos).name].buildable_to then
				minetest.remove_node(pos)
				minetest.set_node(new_pos, node)
				minetest.check_for_falling(new_pos)
			end
		end
	end,
})

minetest.register_on_respawnplayer(respawn_player)
