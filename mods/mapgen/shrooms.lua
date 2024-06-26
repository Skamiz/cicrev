local c_dirt = minetest.get_content_id("cicrev:dirt_with_grass")
local c_water = minetest.get_content_id("cicrev:water_source")
local c_stone = minetest.get_content_id("df_stones:dolomite")
local c_siltstone = minetest.get_content_id("df_stones:siltstone")
local c_chalk = minetest.get_content_id("df_stones:chalk")

minetest.set_mapgen_setting("water_level", "0", true)

--noise parameters
np_3d = {
        offset = 0,
        scale = 10,
        spread = {x = 10, y = 10, z = 10},
        seed = 0,
        octaves = 1,
        persist = 1,
        lacunarity = 1.0,
}

np_2d = {
        offset = 0,
        scale = 10,
        spread = {x = 20, y = 20, z = 20},
        seed = 0,
        octaves = 1,
        persist = 1,
        lacunarity = 1.0,
		-- flags = "noeased",
}

np_terrain_height = {
        offset = 0,
        scale = 5,
        spread = {x = 40, y = 40, z = 40},
        seed = 0,
        octaves = 1,
        persist = 1,
        lacunarity = 1.0,
		-- flags = "noeased",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)
local nobj_th = noise_handler.get_noise_object(np_terrain_height, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    -- local nvals_3d = nobj_3d:get_3d_map_flat(minp)
    local nvals_2d = nobj_2d:get_2d_map_flat(minp)
    local nvals_th = nobj_th:get_2d_map_flat(minp)



    math.randomseed(blockseed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)

				-- local nv_3d = nvals_3d[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]
                local nv_2d = nvals_2d[(z-minp.z) * 80 + (x-minp.x) + 1]
                local nv_th = nvals_th[(z-minp.z) * 80 + (x-minp.x) + 1]
                -- local nv_2d = nvals_2d[flat_area:index(x, emin.y, z)]

				-- local nv_3d = nvals_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 1, z - minp.z + 1)]
				-- local nv_3d = nvals_3d[area:index(x, y, z)]
				-- local nv_3d = nvals_3d[vi]

				-- ni = ni + 1
				-- local nv_3d = nvals_3d[ni]

				-- if y == minp.y then
				-- 	minetest.chat_send_all((z-minp.z) * 80 + (x-minp.x) + 1 .. " | " .. flat_area:index(x, emin.y, z))
				-- end

				local cap_height = nv_th + 20


				if y <= 0 then
					data[vi] = c_water
				end

				if nv_2d > 0 then
					-- if y == 20 then
					if y >= cap_height and y-0.5 <= cap_height + (nv_2d/2) then
						data[vi] = c_siltstone
					elseif y <= cap_height and math.abs(y-(13 + nv_th))/15 * math.abs(y-(13 + nv_th))/15 > ((9 - nv_2d)/10) then
						data[vi] = c_chalk
					end
				end

				if nv_2d + nv_th > y then
					data[vi] = c_stone
				end
				-- if nv_3d > y then
				-- 	data[vi] = c_stone
				-- end

			end
		end
	end

	vm:set_data(data)
	-- vm:update_liquids()
	-- vm:calc_lighting()
	vm:write_to_map()
end)
