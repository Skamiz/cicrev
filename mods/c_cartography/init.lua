cartography = {}
local cartography = cartography

cartography.modname = core.get_current_modname()
cartography.modpath = core.get_modpath(cartography.modname)
cartography.mod_storage = core.get_mod_storage()

cartography.Color, cartography.Gradient = dofile(cartography.modpath .. "/color.lua")
cartography.Image = dofile(cartography.modpath .. "/image.lua")
dofile(cartography.modpath .. "/util.lua")
dofile(cartography.modpath .. "/data_maps.lua")
dofile(cartography.modpath .. "/pages.lua")
dofile(cartography.modpath .. "/formspecs.lua")
dofile(cartography.modpath .. "/map_item.lua")
dofile(cartography.modpath .. "/builtin.lua")



--[[ example usage
cartography.register_data_map("height", {
	width = 640,
	height = 640,
	generate_data = function(self, data_maps)
		local data = {}
		for x = 1, self.width do
			for y = 1, self.height do
				data[#data + 1] = (math.sin(math.rad(x)) + math.sin(math.rad(y))) * 20
			end
		end
		return data
	end,
})

cartography.register_page("height_map", {
	description = "Height Map",
	depends = {"height"},
	get_page_fs = function(self, data_maps)
		local height_map = data_maps["height"]
		local width = height_map.width
		local height = height_map.height

		local color_data = cartography.util.draw_greyscale(height_map, height_map.min, height_map.max)
		color_data = cartography.util.tilt(color_data, height_map, 45)
		local color_string = cartography.util.build_image(color_data, width, height)
		local image_fs = cartography.util.image_fs(color_string, 10, 10)

		return image_fs
	end,
})

cartography.register_page("random", {
	description = "Random Noise",
	get_page_fs = function(self, data_maps)
		local width = 10
		local height = 10
		local color_data = {}
		for x = 1, width do
			for y = 1, height do
				local v = math.random(0, 255)
				color_data[#color_data + 1] = cartography.color.rgb(v, v, v)
			end
		end

		local color_string = cartography.util.build_image(color_data, width, height)
		local image_fs = cartography.util.image_fs(color_string, width, height)

		return image_fs
	end,
})

--]]

-- rename mods global table to be the same as the modname
_G[cartography.modname] = cartography
_G["cartography"] = nil
