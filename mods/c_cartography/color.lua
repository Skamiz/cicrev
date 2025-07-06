local function clamp(min, max, n)
	return math.min(max, math.max(min, n))
end
local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end
local function ilerp(a, b, value)
	return (value - a) / (b - a)
end
local function remap(in_a, in_b, out_a, out_b, value)
	return lerp(out_a, out_b, ilerp(in_a, in_b, value))
end

local color = {}

color.is_valid = function(c)
	return c.r >= 0 and c.r <= 255 and
		c.g >= 0 and c.g <= 255 and
		c.b >= 0 and c.b <= 255
end

color.new = function(r, g, b, a, L, A, B, c, h)
	local c = {
		r = r,
		g = g,
		b = b,
		a = a or 255,
		L = L,
		A = A,
		B = B,
		c = c,
		h = h,
		is_valid = color.is_valid,
	}
end

-- Red, Green, Blue, opAcity
color.rgb = function(r, g, b, a)
	a = a or 255
	local c = {r = r, g = g, b = b, a = a}
	return c
end

color.black = color.rgb(0, 0, 0)
color.white = color.rgb(255, 255, 255)
color.transparent = color.rgb(0, 0, 0, 0)


function color.lerp(color_a, color_b, ratio)
	local new_color = {}
	for k, v in pairs(color_a) do
		new_color[k] = math.round(lerp(color_a[k], color_b[k], ratio))
	end
	return new_color
end
function color.clamp(color_t)
	-- local color_t = table.copy(color_t)
	for k, v in pairs(color_t) do
		color_t[k] = clamp(0, 255, v)
	end
	return color_t
end
function color.from_gradient(gradient, ratio)
	local bound_index = 1
	while bound_index < #gradient and ratio > gradient[bound_index][1] do
		bound_index = bound_index + 1
	end
	if bound_index == 1 then bound_index = 2 end

	local low_bound = gradient[bound_index - 1]
	local high_bound = gradient[bound_index]
	local bound_ratio = remap(low_bound[1], high_bound[1], 0, 1, ratio)

	local grad_color = color.lerp(low_bound[2], high_bound[2], bound_ratio)
	return grad_color
end

local gradient = {}
color.gradient = gradient
gradient.land = {
	{0, {r = 114, g = 173, b = 92, a = 255}},
	{0.5, {r = 231, g = 186, b = 110, a = 255}},
	{1, {r = 225, g = 225, b = 225, a = 255}},
}
gradient.ocean = {
	{0, {r = 60, g = 124, b = 178, a = 255}},
	{1, {r = 240, g = 240, b = 240, a = 255}},
}
gradient.hue = {
	{0/6, {r = 255, g =   0, b =   0, a = 255}},
	{1/6, {r = 255, g = 255, b =   0, a = 255}},
	{2/6, {r =   0, g = 255, b =   0, a = 255}},
	{3/6, {r =   0, g = 255, b = 255, a = 255}},
	{4/6, {r =   0, g =   0, b = 255, a = 255}},
	{5/6, {r = 255, g =   0, b = 255, a = 255}},
	{6/6, {r = 255, g =   0, b =   0, a = 255}},
}

return color
