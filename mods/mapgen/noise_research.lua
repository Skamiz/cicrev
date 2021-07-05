np_generic = {
        offset = 0,
        scale = 1.0,
        spread = {x = 10, y = 10, z = 10},
        seed = 0,
        octaves = 1,
        persist = 1,
        -- lacunarity = 2.0,
}

local side_lenght = 80
local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}

local nobj_generic = get_noise_object(np_generic, chunk_size)

local min, max = 1000, -1000

minetest.register_on_generated(function(minp, maxp, blockseed)
    local noise_values_generic_3d = nobj_generic:get_3d_map_flat(minp)



	for k, v in pairs(noise_values_generic_3d) do
		if v < min then min = v end
		if v > max then max = v end
	end

	minetest.chat_send_all("Min: " .. min .. " | Max: " .. max)
end)
