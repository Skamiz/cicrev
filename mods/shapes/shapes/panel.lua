local shape_name = "panel"

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
			{-8/16, -8/16, -8/16,  8/16,  -4/16,  8/16},
		},
	},
	on_place = shapes.place.slab,
}

shapes.register[shape_name] = function(name, def)
	def = table.copy(def)
	for property, value in pairs(prototype) do
		if def[property] == nil then
			def[property] = type(value) == "table" and table.copy(value) or value
		end
	end
	shapes.add_group(def, "shape", 1)
	shapes.add_group(def, shape_name, 1)

	minetest.register_node(name, def)
end
