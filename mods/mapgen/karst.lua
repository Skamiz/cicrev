-- MIT, originally by MisterE, https://notabug.org/MisterE123/karst_caverns

local c_air = minetest.CONTENT_AIR
local c_gair = minetest.get_content_id("lanterns:light_2")
local c_dirt = minetest.get_content_id("cicrev:dirt_with_grass")
local c_stone = minetest.get_content_id("df_stones:phyllite")
local c_obsidian = minetest.get_content_id("df_stones:obsidian")
local c_glass = minetest.get_content_id("cicrev:glass")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- necesary, otherwise it breaks things

local min_height = -2000
local fallback_max_height = 50

-- 2d, low only
local np_caverns_connector_x = {
	offset = -.75,
	scale = 2,
	spread = {x=30, y=5, z=4},
	octaves = 3,
	seed = 20000,
	persist = 0.4,
	lacunarity = 2,
}
-- 2d, low only
local np_caverns_connector_z = {
	offset = -.75, -- lowering makes
	scale = 2,
	spread = {x=5, y=30, z=30},
	octaves = 3,
	seed = 20000,
	persist = 0.4,
	lacunarity = 2,
}
-- 2d, low only
local np_caverns_rooms = {
	offset = 1.25,
	scale = 2,
	spread = {x = 20, y = 20, z = 20},
	octaves = 2,
	persist = 0.2,
	lacunarity = 4,
}

-- 2d, low only, a large scale noise that prevents cavern formation in large areas
local np_caverns_region = {
	offset = -0.3,
	scale = 1,
	spread = {x=100, y=100, z=100},
	octaves = 6,
	persist = 0.4,
	lacunarity = 1,
}

local np_caverns_modulator = {
	offset = 0,
	scale = 1.3,
	spread = {x=120, y=25, z=120},
	octaves = 4,
	persist = .5,
	lacunarity = 2.5,
}

local np_caverns_rooms_modulator = {
	offset = 0,
	scale = 1.5,
	spread = {x=60, y=13, z=60},
	octaves = 3,
	persist = .5,
	lacunarity = 2.5,
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_caverns_connector_x = noise_handler.get_noise_object(np_caverns_connector_x, chunk_size)
local nobj_caverns_connector_z = noise_handler.get_noise_object(np_caverns_connector_z, chunk_size)
local nobj_caverns_caverns_rooms = noise_handler.get_noise_object(np_caverns_rooms, chunk_size)
local nobj_caverns_region = noise_handler.get_noise_object(np_caverns_region, chunk_size)

local nobj_caverns_modulator = noise_handler.get_noise_object(np_caverns_modulator, chunk_size)
local nobj_caverns_rooms_modulator = noise_handler.get_noise_object(np_caverns_rooms_modulator, chunk_size)

local data = {}

local function remap(val, min_val, max_val, min_map, max_map)
	return (val-min_val)/(max_val-min_val) * (max_map-min_map) + min_map
end

local function lerp(var_a, var_b, ratio)
	return (1-ratio)*var_a + (ratio*var_b)
end

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_caverns_connector_x = nobj_caverns_connector_x:get_2d_map_flat(minp)
    local nvals_caverns_connector_z = nobj_caverns_connector_z:get_2d_map_flat(minp)
    local nvals_caverns_caverns_rooms = nobj_caverns_caverns_rooms:get_2d_map_flat(minp)
    local nvals_caverns_region = nobj_caverns_region:get_2d_map_flat(minp)

    local nvals_caverns_modulator = nobj_caverns_modulator:get_3d_map_flat(minp)
    local nvals_caverns_rooms_modulator = nobj_caverns_rooms_modulator:get_3d_map_flat(minp)

	-- WARNING: heighmap is at the top of the current map chunk for underground areas
	-- making it useless for cavern depth determination
	local heightmap = minetest.get_mapgen_object("heightmap")
    math.randomseed(chunkseed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)
				-- index for flat noise maps, 3d and 2d respectively
				local i3d = (z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1
				local i2d = (z - minp.z) * 80 + (x - minp.x) + 1

				ni = ni + 1


				local height = heightmap and heightmap[i2d] or fallback_max_height

				local caverns_caverns_rooms = nvals_caverns_caverns_rooms[i2d]
				local caverns_region = nvals_caverns_region[i2d]
				local surface_break_adder = 1.5

				-- if y < 50 then
				-- 	data[vi] = c_stone
				-- end

				if y > min_height and y < height - (surface_break_adder) + caverns_caverns_rooms and y > height - (75 + caverns_region) and caverns_region > 0.2 then


					local caverns_connector_x = nvals_caverns_connector_x[i2d]
					local caverns_connector_z =	nvals_caverns_connector_z[i2d]

					local density_caverns_modulator = nvals_caverns_modulator[ni] * 0.5 --+ .75
					local density_caverns_rooms_modulator = nvals_caverns_rooms_modulator[ni] * 0.5

					density_caverns_modulator = remap(density_caverns_modulator, -2, 2, -20, 20)

					if (density_caverns_modulator < 2.8 and density_caverns_modulator > 1
						and (
								lerp(lerp(caverns_connector_x - 0.9, density_caverns_rooms_modulator , 0.4), density_caverns_rooms_modulator, 0.3) > 0
							or lerp(lerp(caverns_connector_z - 0.9, density_caverns_rooms_modulator , 0.4), density_caverns_rooms_modulator, 0.3) > 0
						))
					then
						data[vi] = c_glass
					elseif
					 (density_caverns_modulator > 2.5
						and lerp(density_caverns_rooms_modulator - 0.3, 1 - caverns_caverns_rooms - 0.4, 0.4) > 0
					)

					then
						data[vi] = c_obsidian
					end

				end

			end
		end
	end

	vm:set_data(data)
    -- minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
end)
