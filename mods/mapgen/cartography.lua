

local function clamp(n, min, max)
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
color.black = {r = 0, g = 0, b = 0, a = 255}
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
		color_t[k] = clamp(v, 0, 255)
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

local color_gradient_terrain = {
	{0, {r = 114, g = 173, b = 92, a = 255}},
	{0.5, {r = 231, g = 186, b = 110, a = 255}},
	{1, {r = 225, g = 225, b = 225, a = 255}},
}
local color_gradient_ocean = {
	{0, {r = 240, g = 240, b = 240, a = 255}},
	{1, {r = 60, g = 124, b = 178, a = 255}},
}
local color_gradient_hue = {
	{0/6, {r = 255, g =   0, b =   0, a = 255}},
	{1/6, {r = 255, g = 255, b =   0, a = 255}},
	{2/6, {r =   0, g = 255, b =   0, a = 255}},
	{3/6, {r =   0, g = 255, b = 255, a = 255}},
	{4/6, {r =   0, g =   0, b = 255, a = 255}},
	{5/6, {r = 255, g =   0, b = 255, a = 255}},
	{6/6, {r = 255, g =   0, b =   0, a = 255}},
}



local nobj_terr
minetest.after(0, function()
	-- nobj_terr = minetest.get_perlin(mapgen.np_terrain)
end)
function mapgen.collect_sample(x, z)
	local t0 = minetest.get_us_time()
	local sample = {}
	local height = -vector.new(x, 1000, z):length() + 2000

	height = math.max(height, -500)

	sample.height = height

	return sample
end

local cardinal = {
	{ 1,  0},
	{ 0,  1},
	{-1,  0},
	{ 0, -1},
}
local diagonal = {
	{ 1,  1},
	{-1,  1},
	{-1, -1},
	{ 1, -1},
}
local dirs = {
	{ 1, -1},
	{ 0, -1},
	{-1, -1},
	{-1,  0},
	{-1,  1},
	{ 0,  1},
	{ 1,  1},
	{ 1,  0},
}

local function append_metadata(data)
	local max = data.data_map[1]
	local min = data.data_map[1]
	local total = 0
	for _, val in pairs(data.data_map) do
		if min > val then min = val end
		if max < val then max = val end
		total = total + val
	end
	data.min = min
	data.max = max
	data.average = total / #data.data_map
end
-- use our data to create more data
local function process_cartography_data(cartography_data)
	local steps_x = cartography_data.dimensions.x
	local steps_z = cartography_data.dimensions.z
	local area = VoxelArea(vector.new(1, 1, 1), vector.new(steps_x, 1, steps_z))

	local height_data = cartography_data.categories["height"]
	if height_data then
		local height_map = height_data.data_map

		-- flow datas
		local flow_dir_data = {}
		local flow_strength_data = {}
		for i = 1, #height_map do
			flow_dir_data[i] = 0 --by default asume no flow
			flow_strength_data[i] = 0 --by default asume no flow
			local orig_pos = area:position(i)
			local x_pos = orig_pos.x
			local z_pos = orig_pos.z
			if not (z_pos == 1 or x_pos == 1 or z_pos == steps_z or x_pos == steps_x) then
				local height = height_map[i]
				local flow = 0

				for k, dir in pairs(dirs) do
					local neighbor_height = height_map[area:index(x_pos + dir[1], 1, z_pos + dir[2])]
					local next_flow = height - neighbor_height
					next_flow = next_flow / (math.abs(dir[1]) + math.abs(dir[2]))^0.5
					-- if k%2 == 0 then next_flow = next_flow / 2^0.5 end
					if next_flow > flow then
						flow = next_flow
						flow_dir_data[i] = (k - 0) / #dirs
						flow_strength_data[i] = next_flow
					end
				end
			end
		end
		cartography_data.categories["flow_dir"] = {
			data_map = flow_dir_data,
		}
		append_metadata(cartography_data.categories["flow_dir"])
		table.insert(cartography_data.category_names, "flow_dir")
		cartography_data.categories["flow_strength"] = {
			data_map = flow_strength_data,
		}
		append_metadata(cartography_data.categories["flow_strength"])
		table.insert(cartography_data.category_names, "flow_strength")


		-- shadow data
		local shadow_map = {}
		for i = 1, #height_map do
			shadow_map[i] = 0
			local orig_pos = area:position(i)
			local x_pos = orig_pos.x
			local z_pos = orig_pos.z
			if not (z_pos == 1 or x_pos == 1 or z_pos == steps_z or x_pos == steps_x) then
				local height = height_map[i]
				local shadow = 0
				-- shadow = shadow + (height_map[i-1] - height)
				-- shadow = shadow + (height_map[i+steps_x] - height) / 2^0.5
				-- shadow = shadow + (height_map[i+steps_x-1] - height)
				if height_map[i-1] > height then shadow = shadow + 0.2 end
				if height_map[i+steps_x] > height then shadow = shadow + 0.2 end
				if height_map[i+steps_x-1] > height then shadow = shadow + 0.2 end
				shadow_map[i] = -shadow
			end
		end
		cartography_data.categories["shadow"] = {data_map = shadow_map}
		append_metadata(cartography_data.categories["shadow"])
		table.insert(cartography_data.category_names, "shadow")
	end
end

-- resolution - length of square represented by 1 data point
local function collect_cartography_data(co, min_x, min_z, max_x, max_z, resolution)
	local t0 = minetest.get_us_time()

	local distance_x = max_x - min_x
	local steps_x = math.ceil(distance_x / resolution)
	local step_size_x = distance_x / steps_x
	local distance_z = max_z - min_z
	local steps_z = math.ceil(distance_z / resolution)
	local step_size_z = distance_z / steps_z



	local samples = {}
	local sample_positions = {}

	local lt0 = minetest.get_us_time()

	-- fisrt colect all sample positions
	-- iterrating backwards over Z to make it easier to embed the data into a formspec
	for z = max_z - (step_size_z / 2), min_z, -step_size_z do
		for x = min_x + (step_size_x / 2), max_x, step_size_x do
			table.insert(sample_positions, {math.round(x), math.round(z)})
		end
	end

	-- then colect data samples at the positions
	for i, pos in ipairs(sample_positions) do
		local sample = mapgen.collect_sample(pos[1], pos[2]) -- -2700)
		table.insert(samples, sample)

		if co then
			if minetest.get_us_time() - lt0 > 1000000 then
				print("[mg_tectonic] colecting cartography samples: " .. i .. " / " .. #sample_positions .. " - " .. math.floor((i / #sample_positions) * 100) .. " %")
				minetest.after(0, function()
					coroutine.resume(co)
				end)
				coroutine.yield()
				lt0 = minetest.get_us_time()
			end
		end
	end

	-- organize sample data into data maps
	local categories = {}
	local category_names = {}
	for category, v in pairs(samples[1]) do
		categories[category] = {
			data_map = {},
			min = v,
			max = v,
		}
		table.insert(category_names, category)
	end

	for category, data in pairs(categories) do
		local total = 0
		for i, sample in ipairs(samples) do
			local val = sample[category]
			table.insert(data.data_map, val)
			if data.min > val then data.min = val end
			if data.max < val then data.max = val end
			total = total + val
		end
		data.average = total / #samples
	end

	local cartography_data = {
		dimensions = {
			x = steps_x,
			z = steps_z,
			minp = {x = min_x, z = min_z},
			maxp = {x = max_x, z = max_z},
		},
		categories = categories,
		category_names = category_names,
	}


	print("[mg_tectonic] colected cartography data in " .. (minetest.get_us_time() - t0) / 1000000 .. " seconds")
	print("[mg_tectonic] data dimensions are " .. steps_x .. " X " .. steps_z)
	minetest.chat_send_all("[mg_tectonic] colected cartography data in " .. (minetest.get_us_time() - t0) / 1000000 .. " seconds")

	mapgen.cartography_data = cartography_data
	mapgen.mod_storage:set_string("cartography_data", minetest.serialize(cartography_data))
	process_cartography_data(cartography_data)
end

local function start_collecting_cartography_data(min_x, min_z, max_x, max_z, resolution)
	local co
	co = coroutine.create(function()
		collect_cartography_data(co, min_x, min_z, max_x, max_z, resolution)
	end)
	coroutine.resume(co)
end


local function load_cartography_data()
	if mapgen.cartography_data then return end

	local cartography_data_string = mapgen.mod_storage:get("cartography_data")
	if cartography_data_string then
		local cartography_data = minetest.deserialize(cartography_data_string)
		assert(cartography_data, "Failed to load cartography data from string.")
		mapgen.cartography_data = cartography_data
		process_cartography_data(cartography_data)
		print("[mg_tectonic]: loading cartography data from mod storage. size: " .. cartography_data.dimensions.x .. " X " .. cartography_data.dimensions.z)
	else
		collect_cartography_data(-30000, -30000, 30000, 30000, 750)
	end
end


-- colored terrain map
local function image_terrain_colored(category_data)
	local steps_x = mapgen.cartography_data.dimensions.x
	local steps_z = mapgen.cartography_data.dimensions.z
	local max = category_data.max
	local min = category_data.min
	local shadow_data = mapgen.cartography_data.categories["shadow"]
	local image_data = {}

	for i, val in ipairs(category_data.data_map) do

		if val == nil then
			image_data[#image_data + 1] = {r = 255, g = 0, b = 0, a = 255}
		else
			if val >= 0 then
				local ratio = remap(0, max, 0, 1, val)
				local map_color = color.from_gradient(color_gradient_terrain, ratio)

				if shadow_data then
					local shadow = 0
					shadow = shadow_data.data_map[i]

					-- shadow_ratio = clamp(shadow, -1, 1)
					-- local shadow_ratio = remap(shadow_data.min, shadow_data.max, 1, -1, shadow)
					-- shadow_ratio = clamp(shadow_ratio, 0, 1)
					map_color = color.lerp(map_color, color.black, -shadow)
				end

				image_data[#image_data + 1] = map_color

				-- image_data[#image_data + 1] = color.from_gradient(color_gradient_terrain, ratio)
			else
				local ratio = remap(0, min, 0, 1, val)
				image_data[#image_data + 1] = color.from_gradient(color_gradient_ocean, ratio)
			end
		end
	end
	return image_data
end

-- hue
local function image_hue(category_data)
	local steps_x = mapgen.cartography_data.dimensions.x
	local steps_z = mapgen.cartography_data.dimensions.z
	local max = category_data.max
	local min = category_data.min
	local area = VoxelArea(vector.new(1, 1, 1), vector.new(steps_x, 1, steps_z))
	local image_data = {}

	for i, val in ipairs(category_data.data_map) do

		if val == nil then
			image_data[#image_data + 1] = {r = 255, g = 0, b = 0, a = 255}
		elseif val == 0 then
			image_data[#image_data + 1] = {r = 0, g = 0, b = 0, a = 255}
		else
			image_data[#image_data + 1] = color.from_gradient(color_gradient_hue, val)
		end
	end
	return image_data
end

local function image_grayscale(category_data, min, max)
	local max = max or category_data.max
	local min = min or category_data.min
	local image_data = {}

	for i, val in ipairs(category_data.data_map) do

		if val == nil then
			image_data[#image_data + 1] = {r = 255, g = 0, b = 0, a = 255}
		else
			local intensity = clamp(remap(min, max, 0, 255, val), 0, 255)
			image_data[#image_data + 1] = {r = intensity, g = intensity, b = intensity, a = 255}
			if val < 0 then
				image_data[#image_data] = {r = intensity/2, g = intensity/2, b = intensity, a = 255}
			end
		end
	end
	return image_data
end

local category_draw_modes = {
	["height"] = image_terrain_colored,
	["flow_dir"] = image_hue,
}
local transpartent = {r = 0, g = 0, b = 0, a = 0}
local function slant_image_data(original_image, height_map, filler_color)
	filler_color = filler_color or transpartent
	height_map = height_map or mapgen.cartography_data.categories["height"].data_map

	local slanted_image = {}
	local steps_x = mapgen.cartography_data.dimensions.x
	local steps_z = mapgen.cartography_data.dimensions.z
	local area = VoxelArea(vector.new(1, 1, 1), vector.new(steps_x, 1, steps_z))

	for i, _ in ipairs(original_image) do
		slanted_image[i] = filler_color
	end
	for i, val in ipairs(original_image) do
		local height = height_map[i]
		local orig_pos = area:position(i)
		local orig_z = orig_pos.z
		local orig_x = orig_pos.x

		local new_z = clamp(orig_z - math.round(height*1), 1, steps_z)

		if new_z > orig_z then new_z, orig_z = orig_z, new_z end
		for z = new_z, orig_z do
			local z = math.ceil(remap(1, steps_z, steps_z * 0.25, steps_z, z))
			local new_index = area:index(orig_x, 1, z)
			slanted_image[new_index] = original_image[i]
		end


		-- new_z = math.round(remap(1, steps_z, 0.25 * steps_z, steps_z, new_z))
		-- local new_index = area:index(orig_x, 1, new_z)
		-- slanted_image[new_index] = original_image[i]
	end

	return slanted_image
end
local function get_cartography_map(image_size, category, draw_mode)
	load_cartography_data()

	local steps_x = mapgen.cartography_data.dimensions.x
	local steps_z = mapgen.cartography_data.dimensions.z

	local category_data = mapgen.cartography_data.categories[category]

	local max = category_data.max
	local min = category_data.min

	local image_data
	if category_draw_modes[category] then
		image_data = category_draw_modes[category](category_data)
	else
		image_data = image_grayscale(category_data)
	end

	-- image_data = slant_image_data(image_data)


	local width, height = image_size, image_size
	if steps_x ~= steps_z then
		if steps_x < steps_z then
			width = width * (steps_x / steps_z)
		else
			height = height * (steps_z / steps_x)
		end
	end

	return "image[0,0;" .. width .. "," .. height .. ";[png:" .. minetest.encode_base64(minetest.encode_png(steps_x, steps_z, image_data)) .. "]"
end


local function get_player_marker(player, scale, dimensions)

	local p = 1 / 16
	local pos = player:get_pos()

	local x = remap(dimensions.minp.x, dimensions.maxp.x, -(scale / 2), (scale / 2), pos.x)
	local y = remap(dimensions.minp.z, dimensions.maxp.z, (scale / 2), -(scale / 2), pos.z)

	return "box[" .. x - (p / 2) .. "," .. y - (p / 2) .. ";" .. p .. "," .. p .. ";#F00F]"
end

local function get_fs_tabs(selected)
	load_cartography_data()
	local fs = {
		"tabheader[0,0;category_selector;"
	}
	local n = 1
	for i, category in pairs(mapgen.cartography_data.category_names) do
		fs[#fs + 1] = category
		fs[#fs + 1] = ","
		if selected == category then n = i end
	end
	fs[#fs] = ";" .. n .. "]"
	return table.concat(fs)
end

local function get_map_grid()
	local p = 1/64
	local fs = {
		"box[" .. 5 - p .. ",0;" .. p * 2 .. ",10;#00FF00FF]",
	}
	return table.concat(fs)
end

local function show_cartography_map(player, category)
	local category_data = mapgen.cartography_data.categories[category]
	local fs = {
		"formspec_version[6]",
		"size[11,11]",
		get_fs_tabs(category),
		"container[0.5,0.5]",
		get_cartography_map(10, category),
		-- get_cartography_map_slanted(10, category),
		-- get_map_grid(),
		"container[5,5]",
		-- get_player_marker(player, 10, mapgen.cartography_data.dimensions),
		"container_end[]",
		"label[0,10.25;Min: " .. category_data.min .. "]",
		"label[8,10.25;Max: " .. category_data.max .. "]",
		"label[4,10.25;Avg: " .. category_data.average .. "]",
		"container_end[]",
	}
	fs = table.concat(fs)
	minetest.show_formspec(player:get_player_name(), "mapgen:map_fs", fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "mapgen:map_fs" then return end
	if fields.category_selector then
		local index = tonumber(fields.category_selector)
		show_cartography_map(player, mapgen.cartography_data.category_names[index])
	end
end)



minetest.register_craftitem("mapgen:map", {
	description = "Map",
	inventory_image = "mapgen_map.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		-- entire map
		-- start_collecting_cartography_data(-30000, -30000, 30000, 30000, 93.75)
		-- start_collecting_cartography_data(-300, -300, 300, 300, 0.9375)
		-- start_collecting_cartography_data(-300, -300, 300, 300, 1)
		collect_cartography_data(nil, -320, -320, 320, 320, 1)

		local pos = pointed_thing.under
		-- tight area around player
		-- start_collecting_cartography_data(pos.x - 320, pos.z - 320, pos.x + 320, pos.z + 320, 1)
		-- larger area around player
		-- start_collecting_cartography_data(pos.x - 1280, pos.z - 1280, pos.x + 1280, pos.z + 1280, 4)
	end,
	on_secondary_use = function(itemstack, user, pointed_thing)
		user:set_physics_override({speed = 3})
	end,
	on_use = function(itemstack, user, pointed_thing)
		load_cartography_data()
		show_cartography_map(user, mapgen.cartography_data.category_names[1])
	end,
})
