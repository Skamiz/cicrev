-- These guards are here because 'minetest.get_perlin' isn't aviable at startup,
-- which is when the noise object is registered
-- and 'PerlinNoise()' doesn't take into acount the map seed
local function get_2d(noise, pos)
	-- switched around z and y as this is the usual use case
	return noise.noise_obj:get_2d({x = pos.x, y = pos.z})
end

local function get_3d(noise, pos)
	return noise.noise_obj:get_3d(pos)
end

local function get_2d_map_flat(noise, minp)
	-- switched around z and y as this is the usual use case
	noise.noise_map_obj:get_2d_map_flat({x = minp.x, y = minp.z}, noise.buffer_2d)
	return noise.buffer_2d
end

local function get_3d_map_flat(noise, minp)
	noise.noise_map_obj:get_3d_map_flat(minp, noise.buffer_3d)
	return noise.buffer_3d
end




local blocks_per_chunk = tonumber(minetest.settings:get("chunksize")) or 5
local side_lenght = blocks_per_chunk * 16

-- Returns a noise object which combines the capacity of those returned by
-- 'minetest.get_perlin' and 'minetest.get_perlin_map',
-- and automatically maintains buffer tables for better performance.
function noise_handler.get_noise_object(params, chunk_size)
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

	local noise_object = {
		original_params = params,
		params = table.copy(params),
		chunk_size = chunk_size or {x = side_lenght, y = side_lenght, z = side_lenght},
		buffer_2d = {},
		buffer_3d = {},
		get_2d = get_2d,
		get_3d = get_3d,
		get_2d_map_flat = get_2d_map_flat,
		get_3d_map_flat = get_3d_map_flat,

		amplitude = amplitude,
		min = min,
		max = max,

		noise_obj = nil,
		noise_map_obj = nil,
	}
	minetest.after(0, function()
		noise_object.noise_obj = minetest.get_perlin(noise_object.params, noise_object.chunk_size)
		noise_object.noise_map_obj = minetest.get_perlin_map(noise_object.params, noise_object.chunk_size)
	end)

	return noise_object
end
