local c_stone = minetest.get_content_id("df_stones:phyllite")
local c_water = minetest.get_content_id("cicrev:water_source")

minetest.register_alias("mapgen_stone", "df_stones:phyllite")
minetest.register_alias("mapgen_water_source", "cicrev:water_source")
minetest.register_alias("mapgen_river_water_source", "cicrev:water_source")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- necesary, otherwise it breaks things

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}


local np_2d_continentalnes = {
    offset = 0,
    scale = 1,
    spread = {x = 40, y = 40, z = 40},
    seed = 1,
    octaves = 3,
    persist = 0.5,
    lacunarity = 2.0,
	-- flags = "noeased",
}
local map_c = {
	{-1, -10},
	{-0.5, -8},
	{-0.2, 2},
	{0.3, 4},
	{0.4, 7},
	{0.6, 12},
	-- {0.2, 3},
	{1, 15},
}
local np_2d_peaksvalleys = {
    offset = 0,
    scale = 1,
    spread = {x = 20, y = 20, z = 20},
    seed = 2,
    octaves = 1,
    persist = 0.5,
    lacunarity = 2.0,
	flags = "absvalue",
}
local map_pv = {
	{0, -10},
	{0.1, -1},
	{0.2, 2},
	{0.3, 3},
	{0.7, 8},
	{0.8, 12},
	{0.9, 8},
	{1, 10},
}
local np_2d_erosion = {
	offset = 0,
	scale = 1,
	spread = {x = 60, y = 60, z = 60},
	seed = 3,
	octaves = 2,
	persist = 0.5,
	lacunarity = 2.0,
	flags = "absvalue",
}
local map_e = {
	{0, 1},
	{0.2, 0.8},
	{0.8, 0.2},
	{1, 0},
}

local function lerp(a, b, ratio)
	return (a * (1 - ratio)) + (b * ratio)
end

local function interpret(pv, map)
	for i = 2, #map do
		local a = map[i-1]
		local b = map[i]

		if pv >= a[1] and pv <= b[1] then

			return lerp(a[2], b[2], (pv - a[1]) / (b[1] - a[1]))
		end
	end
	return 0
end

local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_2d_c = noise_handler.get_noise_object(np_2d_continentalnes, chunk_size)
local nobj_2d_pv = noise_handler.get_noise_object(np_2d_peaksvalleys, chunk_size)
local nobj_2d_e = noise_handler.get_noise_object(np_2d_erosion, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_2d_c = nobj_2d_c:get_2d_map_flat(minp)
    local nvals_2d_pv = nobj_2d_pv:get_2d_map_flat(minp)
    local nvals_2d_e = nobj_2d_e:get_2d_map_flat(minp)



    math.randomseed(chunkseed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)

                local nv_2d_c = nvals_2d_c[(z-minp.z) * 80 + (x-minp.x) + 1]
                local nv_2d_pv = nvals_2d_pv[(z-minp.z) * 80 + (x-minp.x) + 1]
                local nv_2d_e = nvals_2d_e[(z-minp.z) * 80 + (x-minp.x) + 1]

				ni = ni + 1


				-- if interpret(nv_2d_c, map_c) + (interpret(nv_2d_pv, map_pv) * (1 - nv_2d_e)) > y then
				-- 	data[vi] = c_stone
				-- end
				-- if interpret(nv_2d_c/1.75, map_c) > y then
				-- 	data[vi] = c_stone
				-- end
				-- if interpret(nv_2d_pv, map_pv) > y then
				-- 	data[vi] = c_stone
				-- end
				-- if interpret(nv_2d_c/1.75, map_c) + interpret(nv_2d_pv, map_pv) > y then
				-- 	data[vi] = c_stone
				-- end
				if interpret(nv_2d_c/1.75, map_c) + (interpret(nv_2d_pv, map_pv) * interpret(nv_2d_e/1.5, map_e)) > y then
					data[vi] = c_stone
				end

				if data[vi] == minetest.CONTENT_AIR and y <= 0 then
					data[vi] = c_water
				end

			end
		end
	end

	biomegen.generate_all(data, area, vm, minp, maxp, chunkseed)

	vm:set_data(data)
    -- minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
end)
