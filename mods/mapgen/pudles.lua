local c_dirt = minetest.get_content_id("cicrev:soil")
local c_grass = minetest.get_content_id("cicrev:dirt_with_grass")
local c_stone = minetest.get_content_id("df_stones:limestone")
local c_water = minetest.get_content_id("cicrev:water_source")

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
        scale = 3,
        spread = {x = 40, y = 40, z = 40},
        seed = 0,
        octaves = 3,
        persist = 0.6,
        lacunarity = 3.0,
		-- flags = "noeased",
}

local side_lenght = 80
local chunk_size = {x = 82, y = 82, z = 82}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_3d = nobj_3d:get_3d_map_flat(minp)
    local nvals_2d = nobj_2d:get_2d_map_flat({x = minp.x - 1, y = minp.y, z = minp.z - 1})



    math.randomseed(blockseed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)

				local nv_3d = nvals_3d[(z - minp.z) * 82 * 82 + (y - minp.y) * 82 + (x - minp.x) + 1]
                local nv_2d = nvals_2d[((z-minp.z) + 1) * 82 + ((x-minp.x) + 1) + 1]
				-- assert(nv_2d, "z = " .. z-minp.z .. " | x = " .. x-minp.x .. " | index: " .. ((z-minp.z) + 1) * 82 + ((x-minp.x) + 1) + 1 .. " | lenght: " .. #nvals_2d)

				-- local nv_3d = nvals_3d[chunk_area:index(x - minp.x + 1, y - minp.y + 1, z - minp.z + 1)]
				-- local nv_3d = nvals_3d[area:index(x, y, z)]
				-- local nv_3d = nvals_3d[vi]

				ni = ni + 1
				-- local nv_3d = nvals_3d[ni]

				-- if y == minp.y then
				-- 	minetest.chat_send_all((z-minp.z) * 80 + (x-minp.x) + 1 .. " | " .. flat_area:index(x, emin.y, z))
				-- end


				if nv_2d > y then
					data[vi] = c_stone
					if nv_2d < y + 1
							and nvals_2d[((z-minp.z) + 1) * 82 + ((x-minp.x) + 0) + 1] > y
							and nvals_2d[((z-minp.z) + 1) * 82 + ((x-minp.x) + 2) + 1] > y
							and nvals_2d[((z-minp.z) + 0) * 82 + ((x-minp.x) + 1) + 1] > y
							and nvals_2d[((z-minp.z) + 2) * 82 + ((x-minp.x) + 1) + 1] > y
							then
						data[vi] = c_water
					end
				end


				if nv_3d > y then
					data[vi] = c_dirt
					if nvals_3d[(z - minp.z) * 82 * 82 + ((y - minp.y) + 1) * 82 + (x - minp.x) + 1] <= (y + 1) then
						data[vi] = c_grass
					end
				end

			end
		end
	end

	vm:set_data(data)
	-- vm:update_liquids()
	-- vm:calc_lighting()
	vm:write_to_map()
end)
