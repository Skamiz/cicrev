local cartography = cartography
local util = {}
cartography.util = util
local Color = cartography.Color
local Gradient = cartography.Gradient

util.dirs_8 = {
	[vector.new( 1,  0, -1)] = math.sqrt(2),
	[vector.new( 0,  0, -1)] = 1,
	[vector.new(-1,  0, -1)] = math.sqrt(2),
	[vector.new(-1,  0,  0)] = 1,
	[vector.new(-1,  0,  1)] = math.sqrt(2),
	[vector.new( 0,  0,  1)] = 1,
	[vector.new( 1,  0,  1)] = math.sqrt(2),
	[vector.new( 1,  0,  0)] = 1,
}

-- return minimum, maximum, and avarage values from a list of numbers
util.get_mma = function(data)
	local min, max, avarage = 0, 0, 0
	local total = 0
	for _, v in ipairs(data) do
		total = total + v
		if v < min then min = v end
		if v > max then max = v end
	end
	avarage = total / #data
	return min, max, avarage
end

-- chack that all data maps 'depends' needs have their data already generated
util.depends_fulfilled = function(depends, data_maps)
	if depends then
		for _, dependency in pairs(depends) do
			if not (data_maps[dependency] and data_maps[dependency].data) then
				return false
			end
		end
	end
	return true
end

-- convert from rgb data table to an image string usable in 'image[]' formspec elements
util.build_image = function(color_data, width, height)
	return "[png:" .. core.encode_base64(core.encode_png(width, height, color_data))
end

util.image_fs = function(image, width, height)
	return "image[0,0;" .. width .. "," .. height .. ";" .. image .. "]"
end


util.clamp = function(min, max, n)
	return math.min(max, math.max(min, n))
end
util.lerp = function(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end
util.ilerp = function(a, b, value)
	return (value - a) / (b - a)
end
util.remap = function(in_a, in_b, out_a, out_b, value)
	return util.lerp(out_a, out_b, util.ilerp(in_a, in_b, value))
end
util.warp = function(min, max, n)
	local step = max - min
	while n < min do
		n = n + step
	end
	while n > max do
		n = n - step
	end
	return n
end

-- height scale: number of samples / actual size of sampled area
util.tilt = function(color_data, height_map, angle)
	angle = math.rad(angle)
	local sin = math.sin(angle)
	local cos = math.cos(angle)

	local slanted_image = {}
	local steps_x = height_map.width
	local steps_z = height_map.height
	local area = height_map.area
	local sample_density = height_map.sample_density or 1


	for i, _ in ipairs(color_data) do
		slanted_image[i] = Color.transparent
	end
	for i, val in ipairs(color_data) do
		local height = height_map.data[i] * sample_density
		local orig_pos = area:position(i)
		local orig_z = orig_pos.z
		local orig_x = orig_pos.x


		local floor_z = (steps_z - orig_z) * cos
		floor_z = math.round(floor_z)
		local new_z = (steps_z - orig_z) * cos + height * sin
		new_z = math.round(new_z)

		if new_z > floor_z then new_z, floor_z = floor_z, new_z end
		for z = new_z, floor_z do
			if area:contains(orig_x, 0, steps_z - z) then
				local new_index = area:index(orig_x, 0, steps_z - z)
				slanted_image[new_index] = color_data[i]
			end
		end
		-- if area:contains(orig_x, 0, steps_z - new_z) then
		-- 	local new_index = area:index(orig_x, 0, steps_z - new_z)
		-- 	slanted_image[new_index] = color_data[i]
		-- end
	end

	return slanted_image
end

util.draw_greyscale = function(data_map, min, max)
	-- local area = data_map.area

	local color_data = {}

	for i, value in pairs(data_map) do
		value = util.remap(min, max, 0, 255, value)
		color_data[i] = Color.rgb(value, value, value)
	end

	-- for i in area:iterp(area.MinEdge, area.MaxEdge) do
	-- 	local value = data_map.data[i]
	-- 	value = util.remap(min, max, 0, 255, value)
	-- 	color_data[i] = Color.rgb(value, value, value)
	-- end

	return color_data
end

local land_gradient = Gradient.from_list({
	Color.rgb(114, 173, 92),
	Color.rgb(231, 186, 110),
	Color.rgb(225, 225, 225),
})
local ocean_gradient = Gradient.from_list({
	Color.rgb(60, 124, 178),
	Color.rgb(240, 240, 240),
})
local hue_gradient = Gradient.from_list({
	Color.rgb(255,   0,   0),
	Color.rgb(255, 255,   0),
	Color.rgb(  0, 255,   0),
	Color.rgb(  0, 255, 255),
	Color.rgb(  0,   0, 255),
	Color.rgb(255,   0, 255),
	Color.rgb(255,   0,   0),
})

util.draw_colored = function(data_map, min, water_level, max)
	local area = data_map.area

	local color_data = {}

	for i in area:iterp(area.MinEdge, area.MaxEdge) do
		local value = data_map.data[i]

		local map_color
		if value < water_level then
			local ratio = util.remap(min, water_level, 0, 1, value)
			map_color = ocean_gradient:sample_normalized(ratio)
		else
			local ratio = util.remap(water_level, max, 0, 1, value)
			map_color = land_gradient:sample_normalized(ratio)
		end

		color_data[i] = map_color
	end

	return color_data
end

util.draw_normal = function(data_map)
	local color_data = {}

	for i, vec in pairs(data_map.data) do
		local c = Color.rgb((vec.x + 1) * (255 / 2), (vec.z + 1) * (255 / 2), (vec.y + 1) * (255 / 2))

		color_data[i] = c
	end

	return color_data
end

util.apply_light = function(color_data, light_data)
	local shaded_color_data = {}
	for i, color in ipairs(color_data) do
		local light = light_data[i]
		shaded_color_data[i] = Color.lerp_rgb(Color.black, color, light)
		-- shaded_color_data[i] = Color.lch(light, color.c, color.h)
	end

	return shaded_color_data
end

util.overlay_rivers = function(color_data, flow_map)
	local river_color_data = {}
	local flow_data = flow_map.data
	local flow_max = flow_map.max
	local blue = Color.rgb(0, 0, 200)

	for i, c in ipairs(color_data) do
		local flow_strength = flow_data[i] / flow_max
		river_color_data[i] = Color.lerp_rgb(c, blue, flow_strength)
	end

	return river_color_data
end
