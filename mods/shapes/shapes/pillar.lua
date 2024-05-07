local shape_name = "pillar"

local prototype = {
	description = "nameless " .. shape_name,
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "facedir",
	groups = {},
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
			{-6/16, -8/16, -6/16,  6/16,  8/16,  6/16},
		},
	},
	on_place = shapes.place.pillar,
}

-- radius is in 16tht of a node aka 1 pixel on a 16*16 texture
shapes.register[shape_name] = function(name, def, radius)
	for property, value in pairs(prototype) do
		if def[property] == nil then
			def[property] = value
		end
	end
	shapes.add_group(def, "shape", 1)
	shapes.add_group(def, shape_name, 1)

	if radius then
		def.node_box = {
			type = "fixed",
			fixed = {
				{-radius/16, -8/16, -radius/16,  radius/16,  8/16,  radius/16},
			},
		}
	end

	minetest.register_node(name, def)
end
