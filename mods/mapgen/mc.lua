local c_stone = minetest.get_content_id("df_stones:phyllite")
local c_water = minetest.get_content_id("cicrev:water_source")
local c_snow_layer = minetest.get_content_id("cicrev:snow_layer")

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
	flags = "noeased",
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

local function ilerp(a, b, value)
	return (value - a) / (b - a)
end

local function remap(in_a, in_b, out_a, out_b, value)
	return lerp(out_a, out_b, ilerp(in_a, in_b, value))

	-- return (out_a * (1 - ((value - in_a) / (in_b - in_a)))) + (out_b * ((value - in_a) / (in_b - in_a)))
end

local function interpret(pv, map)
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

local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

-- local nobj_2d_c = noise_handler.get_noise_object(np_2d_continentalnes, chunk_size)
-- local nobj_2d_pv = noise_handler.get_noise_object(np_2d_peaksvalleys, chunk_size)
-- local nobj_2d_e = noise_handler.get_noise_object(np_2d_erosion, chunk_size)
noise_handler.register_dynamic_noise("continentalnes", np_2d_continentalnes, chunk_size)
noise_handler.register_dynamic_noise("peaksvalleys", np_2d_peaksvalleys, chunk_size)
noise_handler.register_dynamic_noise("erosion", np_2d_erosion, chunk_size)

local data = {}
local param2_data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local t0 = minetest.get_us_time()

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)
	vm:get_param2_data(param2_data)

    -- local nvals_2d_c = nobj_2d_c:get_2d_map_flat(minp)
    -- local nvals_2d_pv = nobj_2d_pv:get_2d_map_flat(minp)
    -- local nvals_2d_e = nobj_2d_e:get_2d_map_flat(minp)
	local nvals_2d_c = noise_handler.noises["continentalnes"]:get_2d_map_flat(minp)
	local nvals_2d_pv = noise_handler.noises["peaksvalleys"]:get_2d_map_flat(minp)
	local nvals_2d_e = noise_handler.noises["erosion"]:get_2d_map_flat(minp)



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
				-- if interpret(nv_2d_c/1.75, map_c) + (interpret(nv_2d_pv, map_pv) * interpret(nv_2d_e/1.5, map_e)) > y then
				-- 	data[vi] = c_stone
				-- end

				if y < interpret(nv_2d_c, map_c) then
					data[vi] = c_stone
				end

				if data[vi] == minetest.CONTENT_AIR and y <= 0 then
					data[vi] = c_water
				end


			end
		end
	end

	-- biomegen.generate_all(data, area, vm, minp, maxp, chunkseed)

	-- for some reason dust doesn't generate in the previous call
	-- vm:get_data(data)
	-- biomegen.dust_top_nodes(data, area, vm, minp, maxp)

	-- dust is placed with param2 of 0, but needs to be 8
	for k, v in pairs(data) do
		if v == c_snow_layer then
			param2_data[k] = 8
		end
	end


	vm:set_data(data)
	vm:set_param2_data(param2_data)
    -- minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
	-- print(((minetest.get_us_time() - t0) / 1000000) .. " s" )
end)


-- SKY
minetest.register_on_joinplayer(
    function(player)
        player:set_sky({
            type = "regular",
            -- base_color = "#a45037",
            clouds = true,
            sky_color = {
                day_sky = "#9ecef3",
                day_horizon = "#b6e3fb",
                -- dawn_sky = "#c8776c",
                -- dawn_horizon = "#fbaf8e",
                -- night_sky = "#232943",
                -- night_horizon = "#323c51",
            },
            -- player:set_clouds({
            --     density = 0.6,
            --     color = "#722b30",
            --     ambient = "#1c080a",
            -- })
        })
    end
)
