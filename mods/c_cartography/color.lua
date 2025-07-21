-- to learn about the Oklab color space visit: https://bottosson.github.io/posts/oklab/



local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end
local function ilerp(a, b, value)
	return (value - a) / (b - a)
end
local function remap(in_a, in_b, out_a, out_b, value)
	return lerp(out_a, out_b, ilerp(in_a, in_b, value))
end

--[[
Color = {r, g, b, L, A, B, c, h, a}

-- new color
.rgb(r, g, b, a)
.lab(L, A, B)
.lch(L, c, h)
.from_colorspec(colorspec) -- core.colorspec_to_colorstring(colorspec)
:copy()

-- lerping
.lerp_rgb(color_a, color_b, ratio)
.lerp_lab(color_a, color_b, ratio)
.lerp_lch(color_a, color_b, ratio)

-- predefined
.white
.black
.transparent
.etc

-- methods
:is_valid()
:to_colorstring -- core.colorspec_to_colorstring(colorspec)


Gradient = {
	points = {
		list of points sorted by position
	}
}
.new(from_color, to_color)
.empty() ?
.from_list(list_of_colors)

:add_point(position, color)
:get_extent() -- return min_position, max_position

:sample(position)
:sample_normalized(position) position <0, 1>, mapped to gradient extent

]]
local function to_linear(v)
	v = v / 255
	if v >= 0.04045 then
		v =  ((v + 0.055) / (1.0 + 0.055))^2.4
	else
		v =  v / 12.92
	end
	return v
end
local function from_linear(v)
	if v >= 0.0031308 then
		v = (1.055) * v^(1.0 / 2.4) - 0.055
	else
		v = v * 12.92
	end
	-- return v * 255
	return math.round(v * 255)
end
local function rgb_to_lab(r, g, b)
	r = to_linear(r)
	g = to_linear(g)
	b = to_linear(b)

	local l = 0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b
	local m = 0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b
	local s = 0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b

	local l_ = l^(1/3)
	local m_ = m^(1/3)
	local s_ = s^(1/3)

	local L = 0.2104542553 * l_ + 0.7936177850 * m_ - 0.0040720468 * s_
	local A = 1.9779984951 * l_ - 2.4285922050 * m_ + 0.4505937099 * s_
	local B = 0.0259040371 * l_ + 0.7827717662 * m_ - 0.8086757660 * s_

	return L, A, B
end
local function lab_to_rgb(L, A, B)
	local l_ = L + 0.3963377774 * A + 0.2158037573 * B
	local m_ = L - 0.1055613458 * A - 0.0638541728 * B
	local s_ = L - 0.0894841775 * A - 1.2914855480 * B

	local l = l_ * l_ * l_
	local m = m_ * m_ * m_
	local s = s_ * s_ * s_

	local r = from_linear(4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s)
	local g = from_linear(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s)
	local b = from_linear(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)

	return r, g, b
end
local function lab_to_lch(A, B)
	local c = math.sqrt(A^2 + B^2)
	local h = math.atan2(B, A)

	return c, h
end
local function lch_to_lab(c, h)
	local A = c * math.cos(h)
	local B = c * math.sin(h)

	return A, B
end

local Color = {}
Color.__index = Color


Color.is_valid = function(c)
	return c.r >= 0 and c.r <= 255 and
		c.g >= 0 and c.g <= 255 and
		c.b >= 0 and c.b <= 255
end

Color.new = function(r, g, b, L, A, B, c, h, a)
	local color = {
		r = r,
		g = g,
		b = b,
		L = L,
		A = A,
		B = B,
		c = c,
		h = h,
		a = a or 255,
	}
	setmetatable(color, Color)

	return color
end

-- Red, Green, Blue, opAcity
Color.rgb = function(r, g, b, a)
	local L, A, B = rgb_to_lab(r, g, b)
	local c, h = lab_to_lch(A, B)

	return Color.new(r, g, b, L, A, B, c, h, a)
end
Color.lab = function(L, A, B, a)
	local r, g, b = lab_to_rgb(L, A, B)
	local c, h = lab_to_lch(A, B)

	return Color.new(r, g, b, L, A, B, c, h, a)
end
Color.lch = function(L, c, h, a)
	h = h % (math.pi * 2)

	local A, B = lch_to_lab(c, h)
	local r, g, b = lab_to_rgb(L, A, B)

	return Color.new(r, g, b, L, A, B, c, h, a)
end
Color.from_colorspec = function(colorspec)
	local color = core.colorspec_to_table(colorspec)

	return Color.rgb(color.r, color.g, color.b, color.a)
end
Color.copy = function(self)
	return Color.new(self.r, self.g, self.b, self.L, self.A, self.B, self.c, self.h, self.a)
end


Color.lerp_rgb = function(color_a, color_b, ratio)
	local r = lerp(color_a.r, color_b.r, ratio)
	local g = lerp(color_a.g, color_b.g, ratio)
	local b = lerp(color_a.b, color_b.b, ratio)
	local a = lerp(color_a.a, color_b.a, ratio)

	return Color.rgb(r, g, b, a)
end

Color.lerp_lab = function(color_a, color_b, ratio)
	local L = lerp(color_a.L, color_b.L, ratio)
	local A = lerp(color_a.A, color_b.A, ratio)
	local B = lerp(color_a.B, color_b.B, ratio)
	local a = lerp(color_a.a, color_b.a, ratio)

	return Color.lab(L, A, B, a)
end

Color.lerp_lch = function(color_a, color_b, ratio)
	local h_a, h_b = color_a.h, color_b.h

	if math.abs(h_a - h_b) > math.pi then
		if h_a < h_b then
			h_a = h_a + 2 * math.pi
		else
			h_b = h_b + 2 * math.pi
		end
	end

	local L = lerp(color_a.L, color_b.L, ratio)
	local c = lerp(color_a.c, color_b.c, ratio)
	local h = lerp(h_a, h_b, ratio)
	local a = lerp(color_a.a, color_b.a, ratio)

	return Color.lch(L, c, h, a)
end


Color.black = Color.rgb(0, 0, 0)
Color.white = Color.rgb(255, 255, 255)
Color.transparent = Color.rgb(0, 0, 0, 0)



Gradient = {}
Gradient.__index = Gradient


Gradient.new = function(from_color, to_color)
	local gradient = {
		points = {
			{pos = 0, color = from_color},
			{pos = 1, color = to_color},
		},
	}
	setmetatable(gradient, Gradient)

	gradient:update()

	return gradient
end

Gradient.from_list = function(color_list)
	local gradient = {
		points = {},
	}
	for pos, color in ipairs(color_list) do
		table.insert(gradient.points, {pos = pos, color = color})
	end
	setmetatable(gradient, Gradient)

	gradient:update()

	return gradient
end


local function sort_gradient(point_a, point_b)
	return point_a.pos < point_b.pos
end
Gradient.update = function(self)
	table.sort(self.points, sort_gradient)

	self.min = self.points[1].pos
	self.max = self.points[#self.points].pos
end

Gradient.add_point = function(self, pos, color)
	table.insert(self.points, {pos = pos, color = color})
	gradient:update()
end


Gradient.sample = function(self, pos)
	local points = self.points

	-- position is out of range, return closes point color
	if pos < self.min then
		return points[1].color:copy()
	end
	if pos > self.max then
		return points[#points].color:copy()
	end

	local point_idx = 1
	while pos > points[point_idx + 1].pos do
		point_idx = point_idx + 1
	end
	local from_point = points[point_idx]
	local to_point = points[point_idx + 1]

	local ratio = remap(from_point.pos, to_point.pos, 0, 1, pos)
	local color = Color.lerp_lab(from_point.color, to_point.color, ratio)

	return color
end

Gradient.sample_normalized = function(self, pos)
	pos = remap(0, 1, self.min, self.max, pos)

	return self:sample(pos)
end

Gradient.get_extent = function(self)
	return self.min, self.max
end


--[[
local cartography = cartography

local steps = 160
core.after(0, function()
	cartography.register_page("lerp_test", {
		description = "Lerp test",
		depends = {},
		get_page_fs = function(self, data_maps)
			local image = cartography.Image.new(steps, 6, Color.lab(0.5, -0.1, 0.0))

			local from_color = Color.rgb(200, 200, 65)
			-- local from_color = Color.rgb(0, 200, 65)
			local to_color = Color.rgb(0, 100, 200)

			-- local from_color = Color.lch(0.7, 0.1, 0 + 0.5)
			-- local to_color = Color.lch(0.7, 0.1, math.pi + 0.5)


			local gradient = Gradient.new(from_color, to_color)
			local test_gradient = Gradient.from_list({
				Color.rgb(114, 173, 92),
				Color.rgb(231, 186, 110),
				Color.rgb(225, 225, 225),
				Color.rgb(200, 50, 100),
				Color.rgb(0, 100, 200),
			})


			for x = 0, steps-1 do
				image:draw_pixel(x + 1, 1, Color.lerp_rgb(from_color, to_color, x/(steps-1)))
			end
			for x = 0, steps-1 do
				image:draw_pixel(x + 1, 2, Color.lerp_lab(from_color, to_color, x/(steps-1)))
			end
			for x = 0, steps-1 do
				image:draw_pixel(x + 1, 3, Color.lerp_lch(from_color, to_color, x/(steps-1)))
			end
			for x = 0, steps-1 do
				local sample_pos = remap(0, steps-1, 0, 1, x)
				local sqare_sample = sample_pos * sample_pos
				local root_sample = math.sqrt(sample_pos)
				image:draw_pixel(x + 1, 4, gradient:sample_normalized(sqare_sample))
				image:draw_pixel(x + 1, 5, gradient:sample_normalized(root_sample))
				image:draw_pixel(x + 1, 6, test_gradient:sample_normalized(sample_pos))
			end


			image:filter(function(color)
				if not color:is_valid() then
					return Color.transparent
				end
				return color
			end)

			local image_fs = image:build_formspec(0, 0, 10, 10)
			return image_fs
		end,
	})
end)

local function all_valid(colors)
	for _, color in pairs(colors) do
		if not color:is_valid() then
			return false
		end
	end
	return true
end
local steps = 16
local function get_colors(L, c)
	local colors = {}
	for x = 1, steps do
		local color = Color.lch(L, c, remap(1, steps + 1, -math.pi, math.pi, x))
		table.insert(colors, color)
	end
	return colors
end

core.after(0, function()
	cartography.register_page("pallete", {
		description = "4 primary colors",
		depends = {},
		get_page_fs = function(self, data_maps)
			local image = cartography.Image.new(steps, steps, Color.lab(0.5, -0.1, 0.0))

			for y = 1, steps do
				local L = remap(1, steps, 1, 0, y)
				local c = 0.0
				local colors = get_colors(L, c)
				while all_valid(colors) do
					c = c + 0.001
					colors = get_colors(L, c)
				end
				c = c - 0.001
				c = c /2
				-- c = 0.123
				-- c = 0.2
				colors = get_colors(L, c)
				for x, color in ipairs(colors) do
					-- local color = Color.lch(L, 0.1, remap(1, 16, -math.pi, math.pi, i))
					image:draw_pixel(x, y, color)
				end
			end


			image:filter(function(color)
				if not color:is_valid() then
					return Color.transparent
				end
				return color
			end)

			local image_fs = image:build_formspec(0, 0, 10, 10)
			return image_fs
		end,
	})
end)

--]]

return Color, Gradient
