local c_dirt = minetest.get_content_id("cicrev:dirt_with_grass")
local c_stone = minetest.get_content_id("cicrev:gravel")
local c_trunk = minetest.get_content_id("cicrev:bark_dark")

minetest.set_mapgen_setting("water_level", "0", true)

--noise parameters
np_3d_branches = {
    offset = 0,
    scale = 4,
    spread = {x = 4, y = 4, z = 4},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
    flags = "absvalue",
}

np_2d = {
    offset = 0,
    scale = 10,
    spread = {x = 40, y = 40, z = 40},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
	flags = "noeased",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d_b = noise_handler.get_noise_object(np_3d_branches, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)

local data = {}

local canopy_height = 32

minetest.register_on_generated(function(minp, maxp, blockseed)
    if maxp.y < 0 or minp.y > 0 then return end
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_3d_b = nobj_3d_b:get_3d_map_flat(minp)
    local nvals_2d = nobj_2d:get_2d_map_flat(minp)

    local midp = vector.new(math.floor((minp.x + maxp.x)/2), math.floor((minp.y + maxp.y)/2), math.floor((minp.z + maxp.z)/2))


    math.randomseed(blockseed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)

				local nv_3d_b = nvals_3d_b[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]
                -- local nv_2d = nvals_2d[(z-minp.z) * 80 + (x-minp.x) + 1]

				ni = ni + 1
				-- local nv_3d = nvals_3d[ni]

				-- if y == minp.y then
				-- 	minetest.chat_send_all((z-minp.z) * 80 + (x-minp.x) + 1 .. " | " .. flat_area:index(x, emin.y, z))
				-- end


				-- if nv_2d > y then
				-- 	data[vi] = c_dirt
				-- end
                local dist = math.pow(x-midp.x, 2) + math.pow(z-midp.z, 2)
				if dist < math.pow(8, 2)and dist > math.pow(5, 2) then
					data[vi] = c_trunk
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
