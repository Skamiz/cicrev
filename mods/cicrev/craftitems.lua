minetest.register_craftitem("cicrev:stick", {
	description = "Stick",
	inventory_image = "cicrev_stick.png",
	stack_max = 64,
})
minetest.register_craftitem("cicrev:flint", {
	description = "Flint stone",
	inventory_image = "cicrev_flint.png",
	stack_max = 64,
})
minetest.register_craftitem("cicrev:grass", {
	description = "Grass bundle",
	inventory_image = "cicrev_grass.png",
	stack_max = 64,
})
minetest.register_craftitem("cicrev:grass_rope", {
	description = "Grass Rope",
	inventory_image = "cicrev_grass_rope.png",
	stack_max = 64,
})



minetest.register_craftitem("cicrev:coal", {
	description = "Coal",
	inventory_image = "cicrev_coal.png",
	stack_max = 16,
	on_use = function(itemstack, user, pointed_thing)
		if pointed_thing.type ~= "node" then return end
		local node = minetest.get_node(pointed_thing.under)
		local node_def = minetest.registered_nodes[node.name]
		-- minetest.chat_send_all(node_def.drawtype)
		if node_def.drawtype ~= "normal" then return end
		local pos = pointed_thing.above
		local param2 = get_arrow_rotation(user, pointed_thing)

		minetest.set_node(pos, {name = "cicrev:coal_arrow", param2 = param2})
	end
})



local pos1, pos2, line

local function place_line(line, to_place)
	for _, v in ipairs(line) do
		minetest.set_node(v, {name = to_place})
	end
end
