### Noise Handler [noise_handler]

Utitlity mod that simplifies working with the builtin noise generators
by collecting generating functions into one object and autamtically
managing re-use of data tables.


## API

noise_handler.get_noise_object(noise_parameters, chunk_size)
- returns a noise object, that unifies the single and map value generators
- [noise_parameters](https://github.com/luanti-org/luanti/blob/5.12.0/doc/lua_api.md?plain=1#L4590)
- chunk_size, dimensions of noise maps
optional, defaults to size of a mapgen chunk

# Example:

```lua

-- define noise parameters
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
-- create a noise object
-- chunk_size is optional and defaults to the size of a mapgen chunk
local nobj = noise_handler.get_noise_object(np, chunk_size)

-- now you can treat the following functions like they are one object
local nv_2d = nobj:get_2d(pos)
local nv_3d = nobj:get_3d(pos)
local nm_2d_flat = nobj:get_2d_map_flat(minp)
local nm_3d_flat = nobj:get_3d_map_flat(minp)

```

for 2d function, the noise object switches the Y and Z axis of the requested
cooridnates, since most usecasess will want to spread the noise hoarizontally
