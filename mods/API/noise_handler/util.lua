function noise_handler.flags_to_table(flags)
	local ft = {}
	for flag in flags:gmatch("[%a%d]+") do
		if flag:match("^no") then
			flag = flag:match("^no([%a%d]+)")
			ft[flag] = false
		else
			ft[flag] = true
		end
	end
	return ft
end

function noise_handler.table_to_flags(ft)
	local flags = {}
	for flag, v in pairs(ft) do
		if v then
			flags[#flags + 1] = flag
		else
			flags[#flags + 1] = "no" .. flag
		end
	end
	return table.concat(flags, ",")
end

function noise_handler.get_noise_meta(params)
	local ft = noise_handler.flags_to_table(params.flags or "")
	if ft.defaults == nil and ft.eased == nil then
		ft.defaults = true
	end
	params.flags = noise_handler.table_to_flags(ft)


	local amplitude = 0
	for i = 1, params.octaves do
		amplitude = amplitude + math.pow(params.persist, i - 1)
	end
	amplitude = amplitude * params.scale


	local min = -amplitude + params.offset
	local max =  amplitude + params.offset
	if ft.absvalue then
		if max < 0 then
			max, min = -min, -max
		elseif min < 0 then
			min = 0
		end
	end

	local noise_meta = {
		amplitude = amplitude,
		min = min,
		max = max,
	}

	return noise_meta
end


local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end

local function ilerp(a, b, value)
	return (value - a) / (b - a)
end

local function remap(in_a, in_b, out_a, out_b, value)
	return lerp(out_a, out_b, ilerp(in_a, in_b, value))

	-- return (out_a * (1 - ((value - in_a) / (in_b - in_a)))) + (out_b * ((value - in_a) / (in_b - in_a)))
end

function noise_handler.interpret(pv, map)
	if (not map) or #map == 0 then return pv end
	if #map == 1 then
		return pv + (map[1][2] - map[1][1])
	end

	local n = 2
	for i = 2, #map do
		local a = map[i-1]
		local b = map[i]
		n = i

		if pv < a[1] then break end
		if pv >= a[1] and pv <= b[1] then

			return remap(a[1], b[1], a[2], b[2], pv)
		end
	end
	local a = map[n-1]
	local b = map[n]
	return lerp(a[2], b[2], (pv - a[1]) / (b[1] - a[1]))


	-- return 0
end
