-- how to use:

-- create a noise object
np = {
    offset = 0,
    scale = 1,
    spread = {x = 40, y = 40, z = 40},
    seed = 1,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
	flags = "absvalue",
}
-- chunk_size is optional and defaults to the size of a mapgen chunk
local nobj = noise_handler.get_noise_object(np, chunk_size)

-- now you can treat the following functions like they are one object
local nv_2d = nobj:get_2d(minp)
local nv_3d = nobj:get_3d(minp)
local nm_2d_flat = nobj:get_2d_map_flat(minp)
local nm_3d_flat = nobj:get_3d_map_flat(minp)

--[[
	what the noise object does internaly

	handles the perlin and perlin_map objects
	manages buffer tables for calls which produce maps to optimize memory usage
	switches z coordinate to y for 2d functions
		since the usual use-case is horizontal
--]]
