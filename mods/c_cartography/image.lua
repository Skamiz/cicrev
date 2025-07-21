--[[
image = {
	width = width,
	height = height,
	area = VoxelArea(vector.new(1, 0, 1), vector.new(width, 0, height))
	color_data = {width*height},

	meta table functions
}


:clear(color)

:draw_pixel(pos_x, pos_y, color)
:draw_line(from_x, from_y, to_x, to_y, color)
:draw_square(from_x, from_y, to_x, to_y, color)
:draw_circle(pos_x, pos_y, radius, color)
:draw_image(pos_x, pos_y, image)

:set_color_data(color_data)?
:trim()

-- :tilt(angle, height_map)
:cutout(from_x, from_y, to_x, to_y)
:copy()

:build_texture()
:build_formspec(pos_x, pos_y, fs_width, fs_height)


]]

local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end


local Image = {}
Image.__index = Image

-- create new image, filled with a single color
Image.new = function(width, height, color)
	local image = {
		width = width,
		height = height,
		area = VoxelArea(vector.new(1, 0, 1), vector.new(width, 0, height)),
	}
	setmetatable(image, Image)

	image:clear(color)

	return image
end

-- create a new image with specified color_data
Image.from_data = function(width, height, color_data)
	local image = {
		width = width,
		height = height,
		color_data = color_data,
		area = VoxelArea(vector.new(1, 0, 1), vector.new(width, 0, height)),
	}
	setmetatable(image, Image)

	return image
end


-- set all pixels to color
Image.clear = function(self, color)
	local color_data = {}
	for i = 1, self.width * self.height do
		table.insert(color_data, color)
	end

	self.color_data = color_data
end

Image.draw_pixel = function(self, pos_x, pos_y, color)
	if self.area:contains(pos_x, 0, pos_y) then
		local idx = self.area:index(pos_x, 0, pos_y)
		self.color_data[idx] = color
	end
end

Image.draw_line = function(self, from_x, from_y, to_x, to_y, color)
	local area = self.area
	local color_data = self.color_data

	local steps = math.max(math.abs(from_x - to_x), math.abs(from_y - to_y))

	for i = 0, steps do
		local x = math.round(lerp(from_x, to_x, i / steps))
		local y = math.round(lerp(from_y, to_y, i / steps))

		if area:contains(x, 0, y) then
			local idx = area:index(x, 0, y)
			if not type(idx) == "number" then
				print(dump(idx))
			end
			color_data[idx] = color
		end
	end
end

Image.draw_square = function(self, from_x, from_y, to_x, to_y, color)
	self:draw_line(from_x, from_y, from_x, to_y, color)
	self:draw_line(from_x, from_y, to_x, from_y, color)
	self:draw_line(to_x, from_y, to_x, to_y, color)
	self:draw_line(from_x, to_y, to_x, to_y, color)
end

Image.draw_circle = function(self, pos_x, pos_y, radius, color)
	-- local area = self.area
	-- local color_data = self.color_data

	local l = radius
	local s = 0

	while l >= s do
		self:draw_pixel(pos_x + l, pos_y + s, color)
		self:draw_pixel(pos_x - l, pos_y + s, color)
		self:draw_pixel(pos_x + l, pos_y - s, color)
		self:draw_pixel(pos_x - l, pos_y - s, color)

		self:draw_pixel(pos_x + s, pos_y + l, color)
		self:draw_pixel(pos_x - s, pos_y + l, color)
		self:draw_pixel(pos_x + s, pos_y - l, color)
		self:draw_pixel(pos_x - s, pos_y - l, color)

		s = s + 1
		l = math.round(math.sqrt(radius^2 - s^2))
	end
end

-- paste am image into antoher one
Image.draw_image = function(self, pos_x, pos_y, image)
	for x = 1, image.width do
		for y = 1, image.height do
			local from_idx = image.area:index(x, 0, y)
			local to_idx = self.area:index((x + pos_x) - 1, 0, (y + pos_y) - 1)

			self.color_data[to_idx] = image.color_data[from_idx]
		end
	end
end


-- apply filter on all pixels
Image.filter = function(self, filter)
	local color_data = self.color_data
	for idx, color in ipairs(color_data) do
		color_data[idx] = filter(color)
	end
end


-- return an image containing a subsection of the calling images color_data
Image.cutout = function(self, from_x, from_y, to_x, to_y)
	if to_x < from_x then
		from_x, to_x = to_x, from_x
	end
	if to_y < from_y then
		from_y, to_y = to_y, from_y
	end

	local width = (to_x - from_x) + 1
	local height = (to_y - from_y) + 1
	local color_data = {}

	for idx in self.area:iter(from_x, 0, from_y, to_x, 0, to_y) do
		table.insert(color_data, self.color_data[idx])
	end

	local cutout = Image.from_data(width, height, color_data)
	return cutout
end

-- returns a copy of the calling image
Image.copy = function(self)
	local color_data = table.copy(self.color_data)
	local copy = Image.from_data(self.width, self.height, color_data)
	return copy
end


-- returns image 'texture'
Image.build_texture = function(self)
	return "[png:" .. core.encode_base64(core.encode_png(self.width, self.height, self.color_data))
end

-- returns 'image[]' formspec element
Image.build_formspec = function(self, fs_pos_x, fs_pos_y, fs_width, fs_height)
	local image_texture = self:build_texture()
	return "image[" .. fs_pos_x .. "," .. fs_pos_y .. ";" .. fs_width .. "," .. fs_height .. ";" .. image_texture .. "]"
end


--[[ Image test cartography page.
local cartography = cartography
local color = cartography.color

core.after(0, function()
	cartography.register_page("image_test", {
		description = "Image test",
		depends = {},
		get_page_fs = function(self, data_maps)
			local image = Image.new(160, 160, color.rgb(255, 127, 63))

			image:draw_pixel(10, 10, color.rgb(0, 0, 255))
			image:draw_line(1, 160, 160, 1, color.rgb(0, 255, 0))
			image:draw_square(17, 17, 64, 32, color.rgb(255, 255, 0))
			image:draw_circle(100, 100, 10, color.rgb(255, 255, 255))

			local cutout = image:cutout(5, 5, 20, 30)
			image:draw_image(10, 50, cutout)

			local image_fs = image:build_formspec(0, 0, 10, 10)
			return image_fs
		end,
	})
end)
--]]


return Image
