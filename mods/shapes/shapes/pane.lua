local shape_name = "pane"

local prototype = {
	description = "nameless " .. shape_name,
	paramtype = "light",
	sunlight_propagates = true,
	groups = {},
	drawtype = "nodebox",
	connects_to = {"group:solid_node", "group:" .. shape_name},
	node_box = {
		type = "connected",
		fixed = {-1/16, -8/16, -1/16, 1/16, 8/16, 1/16},
		connect_front = {-1/16, -8/16, -8/16, 1/16, 8/16, -1/16},
        connect_left = {-8/16, -8/16, -1/16, -1/16, 8/16, 1/16},
        connect_back = {-1/16, -8/16, 1/16, 1/16, 8/16, 8/16},
        connect_right = {1/16, -8/16, -1/16, 8/16, 8/16, 1/16},
	}
}

shapes.register[shape_name] = function(name, def)
	def = table.copy(def)
	for property, value in pairs(prototype) do
		if def[property] == nil then
			def[property] = value
		end
	end
	shapes.add_group(def, "shape", 1)
	shapes.add_group(def, shape_name, 1)

	minetest.register_node(name, def)
end
