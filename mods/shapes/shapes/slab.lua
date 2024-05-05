local shape_name = "slab"

local prototype = {
	description = "nameless " .. shape_name,
	paramtype = "light",
	paramtype2 = "facedir",
	node_placement_prediction = "",
	groups = {},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-8/16, -8/16, -8/16,  8/16,  0/16,  8/16},
		},
	},
	on_place = shapes.place.slab,
}

shapes.register[shape_name] = function(name, def)
	for property, value in pairs(prototype) do
		if def[property] == nil then
			def[property] = value
		end
	end
	shapes.add_group(def, "shape", 1)
	shapes.add_group(def, shape_name, 1)

	minetest.register_node(name, def)
end
