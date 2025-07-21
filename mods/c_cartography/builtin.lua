local cartography = cartography
local util = cartography.util
local builtins = {}
cartography.builtins = builtins

local WATER_LEVEL = tonumber(core.settings:get("water_level")) or 0

local function data_map_registered(data_map_name)
	local data_map = cartography.registered_data_maps[data_map_name]
	assert(data_map, "Can not register suplementary data map withtou first registering a '" .. data_map_name .. "'")
	return data_map
end

builtins.register_heigh_page = function()
	cartography.register_page("height", {
		description = "Height Map",
		depends = {"height_map"},
		get_page_fs = function(self, data_maps)
			local height_map = data_maps["height_map"]
			local width = height_map.width
			local height = height_map.height

			local color_data = util.draw_greyscale(height_map.data, height_map.min, height_map.max)
			-- color_data = util.tilt(color_data, height_map, 45)
			local color_string = util.build_image(color_data, width, height)
			local image_fs = util.image_fs(color_string, 10, 10)

			-- TODO: attach mma information
			return image_fs
		end,
	})
end

builtins.register_normal_map = function()
	local height_map = data_map_registered("height_map")

	cartography.register_data_map("normal_map", {
		width = height_map.width,
		height = height_map.height,
		depends = {"height_map"},
		generate_data = function(self, data_maps)
			local up = vector.new(0, 1, 0)
			local zero = vector.zero()
			local height_map = data_maps["height_map"]
			local height_data = height_map.data
			local sample_density = height_map.sample_density or 1
			local area = height_map.area

			local data = {}

			for i = 1, #height_data do
				data[i] = up
			end

			local d_north = vector.new(0, 0, 1)
			local d_south = vector.new(0, 0, -1)
			local d_east = vector.new(1, 0, 0)
			local d_west = vector.new(-1, 0, 0)

			local up_strength = 4 / sample_density

			for i in area:iter(2, 0, 2, height_map.width - 1, 0, height_map.height - 1) do
				local center_pos = area:position(i)

				local north = height_data[area:indexp(center_pos + d_north)]
				local south = height_data[area:indexp(center_pos + d_south)]
				local east = height_data[area:indexp(center_pos + d_east)]
				local west = height_data[area:indexp(center_pos + d_west)]

				local normal = vector.new(-2 * (east - west), up_strength, -2 * (south - north))


				data[i] = normal:normalize()
			end

			return data
		end,
	})

	cartography.register_page("normal", {
		description = "Normal Map",
		depends = {"normal_map"},
		get_page_fs = function(self, data_maps)
			local normal_map = data_maps["normal_map"]
			-- local height_map = data_maps["height_map"]
			local width = normal_map.width
			local height = normal_map.height

			local color_data = util.draw_normal(normal_map)
			-- color_data = util.tilt(color_data, height_map, 45)
			local color_string = util.build_image(color_data, width, height)
			local image_fs = util.image_fs(color_string, 10, 10)

			return image_fs
		end,
	})
end

builtins.register_light_map = function(sun_vector)
	local normal_map = data_map_registered("normal_map")
	local light_vec = sun_vector or vector.new(-1, 1, -1):normalize() -- points to sun

	cartography.register_data_map("light_map", {
		width = normal_map.width,
		height = normal_map.height,
		depends = {"normal_map"},
		generate_data = function(self, data_maps)
			local normal_map = data_maps["normal_map"]
			local data = {}

			for i, normal in pairs(normal_map.data) do
				local light = light_vec:dot(normal)
				data[i] = light
			end

			return data
		end,
	})

	cartography.register_page("light", {
		description = "Light Map",
		depends = {"light_map"},
		get_page_fs = function(self, data_maps)
			local light_map = data_maps["light_map"]
			local width = light_map.width
			local height = light_map.height

			local color_data = util.draw_greyscale(light_map.data, light_map.min, light_map.max)
			-- color_data = util.tilt(color_data, light_map, 45)
			local color_string = util.build_image(color_data, width, height)
			local image_fs = util.image_fs(color_string, 10, 10)

			return image_fs
		end,
	})
end

builtins.regsiter_flow_maps = function()
	local height_map = data_map_registered("height_map")

	cartography.register_data_map("flow_to_map", {
		width = height_map.width,
		height = height_map.height,
		depends = {"height_map"},
		generate_data = function(self, data_maps)
			local height_map = data_maps["height_map"]
			local height_data = height_map.data
			local area = height_map.area

			local data = {}

			for i, height in pairs(height_data) do
				if height > WATER_LEVEL then
					local pos = area:position(i)

					local lowest_slope_index = nil
					local steepest_slope = 0
					for offset, distance in pairs(util.dirs_8) do
						local neighbor_pos = pos + offset

						if area:containsp(neighbor_pos) then
							local neighbor_index = area:indexp(neighbor_pos)
							local neighbor_height = height_data[neighbor_index]

							local slope = (neighbor_height - height) / distance
							if slope < steepest_slope then
								steepest_slope = slope
								lowest_slope_index = neighbor_index
							end
						end

					end

					data[i] = lowest_slope_index
				end
			end

			return data
		end,
	})
	cartography.register_data_map("flow_from_map", {
		width = height_map.width,
		height = height_map.height,
		depends = {"flow_to_map"},
		generate_data = function(self, data_maps)
			local flow_to_map = data_maps["flow_to_map"]
			local flow_to_data = flow_to_map.data
			local area = flow_to_map.area

			local data = {}

			for i, dest in pairs(flow_to_data) do
				if not data[dest] then
					data[dest] = {}
				end
				table.insert(data[dest], i)
			end

			return data
		end,
	})

	local function get_flow_at(i, data, flow_from_data)
		local sources = flow_from_data[i]
		if not sources then
			data[i] = 1
		else
			local flow = 0
			for _, source in pairs(sources) do
				flow = flow + get_flow_at(source, data, flow_from_data)
			end
			data[i] = flow
		end

		return data[i]
	end

	cartography.register_data_map("flow_amount_map", {
		width = height_map.width,
		height = height_map.height,
		depends = {"flow_to_map", "flow_from_map"},
		generate_data = function(self, data_maps)
			local flow_to_map = data_maps["flow_to_map"]
			local flow_to_data = flow_to_map.data
			local area = self.area

			local flow_from_map = data_maps["flow_from_map"]
			local flow_from_data = flow_from_map.data

			local data = {}
			for i in area:iterp(area.MinEdge, area.MaxEdge) do
				data[i] = 0
			end

			-- for i in area:iterp(area.MinEdge, area.MaxEdge) do
			-- 	if flow_to_data[i] then
			-- 		local dest_index = flow_to_data[i]
			-- 		while dest_index do
			-- 			data[dest_index] = data[dest_index] + 1
			-- 			dest_index = flow_to_data[dest_index]
			-- 		end
			-- 	end
			-- end

			for i, sources in pairs(flow_from_data) do
				if not flow_to_data[i] then -- this is a river end
					data[i] = get_flow_at(i, data, flow_from_data)
				end
			end

			-- for i, flow_amount in pairs(data) do
			-- 	data[i] = math.log(flow_amount + 1)
			-- end

			return data
		end,
	})

	cartography.register_page("rivers", {
		description = "Rivers",
		depends = {"flow_amount_map", "height_map"},
		get_page_fs = function(self, data_maps)
			local height_map = data_maps["height_map"]
			local river_map = data_maps["flow_amount_map"]
			local river_data = river_map.data
			local width = river_map.width
			local height = river_map.height


			local color_data = util.draw_greyscale(river_data, river_map.min, river_map.max)
			-- local color_data = util.draw_greyscale(flow_amount, 0, math.log(max_flow))
			-- color_data = util.tilt(color_data, height_map, 45)
			local color_string = util.build_image(color_data, width, height)
			local image_fs = util.image_fs(color_string, 10, 10)

			return image_fs
		end,
	})
end

builtins.regsiter_terrain_page = function()
	cartography.register_page("terrain", {
		description = "Terrain Map",
		depends = {"height_map", "light_map", "flow_amount_map"},
		get_page_fs = function(self, data_maps)
			local height_map = data_maps["height_map"]
			local flow_map = data_maps["flow_amount_map"]
			local light_data = data_maps["light_map"].data
			local width = height_map.width
			local height = height_map.height

			local color_data = util.draw_colored(height_map, height_map.min, WATER_LEVEL, height_map.max)
			color_data = util.overlay_rivers(color_data, flow_map)
			color_data = util.apply_light(color_data, light_data)
			color_data = util.tilt(color_data, height_map, 45)
			local color_string = util.build_image(color_data, width, height)
			local image_fs = util.image_fs(color_string, 10, 10)

			return image_fs
		end,
	})
end
