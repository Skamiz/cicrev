local cartography = cartography
local util = {}
cartography.util = util
local color = cartography.color

util.dirs_8 = {
	vector.new( 1,  0, -1),
	vector.new( 0,  0, -1),
	vector.new(-1,  0, -1),
	vector.new(-1,  0,  0),
	vector.new(-1,  0,  1),
	vector.new( 0,  0,  1),
	vector.new( 1,  0,  1),
	vector.new( 1,  0,  0),
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

util.tilt = function(color_data, height_map, angle)
	angle = math.rad(angle)
	local sin = math.sin(angle)
	local cos = math.cos(angle)

	local slanted_image = {}
	local steps_x = height_map.width
	local steps_z = height_map.height
	local area = height_map.area

	for i, _ in ipairs(color_data) do
		slanted_image[i] = cartography.color.transparent
	end
	for i, val in ipairs(color_data) do
		local height = height_map.data[i]
		local orig_pos = area:position(i)
		local orig_z = orig_pos.z
		local orig_x = orig_pos.x


		local floor_z = (steps_z - orig_z) * cos
		floor_z = math.round(floor_z)
		local new_z = (steps_z - orig_z) * cos + height * sin
		new_z = math.round(new_z)

		if new_z > floor_z then new_z, floor_z = floor_z, new_z end
		for z = new_z, floor_z do
			if area:contains(orig_x, 1, steps_z - z) then
				local new_index = area:index(orig_x, 1, steps_z - z)
				slanted_image[new_index] = color_data[i]
			end
		end
		-- if area:contains(orig_x, 1, steps_z - new_z) then
		-- 	local new_index = area:index(orig_x, 1, steps_z - new_z)
		-- 	slanted_image[new_index] = color_data[i]
		-- end
	end

	return slanted_image
end

util.draw_greyscale = function(data_map, min, max)
	local area = data_map.area

	local color_data = {}

	for i in area:iterp(area.MinEdge, area.MaxEdge) do
		local value = data_map.data[i]
		value = util.remap(min, max, 0, 255, value)
		color_data[i] = cartography.color.rgb(value, value, value)
	end

	return color_data
end

util.draw_colored = function(data_map, min, water_level, max)
	local area = data_map.area

	local color_data = {}

	for i in area:iterp(area.MinEdge, area.MaxEdge) do
		local value = data_map.data[i]

		local map_color
		if value <= water_level then
			local ratio = util.remap(min, water_level, 0, 1, value)
			map_color = color.from_gradient(color.gradient.ocean, ratio)
		else
			local ratio = util.remap(water_level, max, 0, 1, value)
			map_color = color.from_gradient(color.gradient.land, ratio)
		end

		color_data[i] = map_color
	end

	return color_data
end

util.draw_normal = function(data_map)
	local color_data = {}

	for i, vec in pairs(data_map.data) do
		local c = color.rgb((vec.x + 1) * (255 / 2), (vec.z + 1) * (255 / 2), (vec.y + 1) * (255 / 2))

		color_data[i] = c
	end

	return color_data
end

util.apply_light = function(color_data, light_data)
	local shaded_color_data = {}
	for i, c in ipairs(color_data) do
		local light = light_data[i]
		shaded_color_data[i] = color.lerp(c, color.black, 1-light)
	end

	return shaded_color_data
end
