local c_plating = minetest.get_content_id("df_stones:obsidian")
local c_core = minetest.get_content_id("cicrev:corite")

minetest.set_mapgen_setting("water_level", "0", true)

--noise parameters
-- cracks in the shells of the great rings
np_3d_ring = {
    offset = 0,
    scale = 1,
    spread = {x = 8, y = 8, z = 8},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
    -- flags = "absvalue",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d_r = noise_handler.get_noise_object(np_3d_ring, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)

	if maxp.y < 0 or minp.y > 0 then return end
	math.randomseed(chunkseed)
	-- if math.random() <= 1/25 then return end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local height_data = minetest.get_mapgen_object("heightmap")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)

	local nvals_3d_r = nobj_3d_r:get_3d_map_flat(minp)

	-- major radius
	local R = math.random(10, 30)
	-- mineor 'radius'
	local r = math.random(1, 3)
	-- y is decreased to bias rings towards not laying flat on the ground
	local rdir = vector.new(math.random() - 0.5, (math.random() - 0.5)/2, math.random() - 0.5):normalize()
	local rpos = {}

	rpos.x = math.random(minp.x + R + r + 1, maxp.x - (R + r + 1))
	rpos.y = math.random(minp.y + R + r + 1, maxp.y - (R + r + 1))
	rpos.z = math.random(minp.z + R + r + 1, maxp.z - (R + r + 1))

    if height_data then
		rpos.y = height_data[(rpos.z - minp.z) * 80 + (rpos.x - minp.x) + 1]
		rpos.y = math.min(math.max(rpos.y, minp.y + R + r + 1), maxp.y - (R + r + 1))
	end

	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)

				-- ring core
				local dist = math.pow(rpos.x - x, 2) + math.pow(rpos.z - z, 2) + math.pow(rpos.y - y, 2)
				-- first check if node is certain distance from the middle position
				if dist > math.pow(R - r, 2) and dist < math.pow(R + r, 2) and
					-- then check how close it is to the plane specified by the rings orientation
				 	math.abs((x-rpos.x) * rdir.x + (y-rpos.y) * rdir.y + (z-rpos.z) * rdir.z) <= r then
					data[vi] = c_core
				end

				-- ring plating
				local nv_3d_r = nvals_3d_r[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]

				if data[vi] ~= c_core and nv_3d_r < 0.3 and
						dist > math.pow((R - r) - 1, 2) and dist < math.pow((R + r) + 1, 2) and
					 	math.abs((x-rpos.x) * rdir.x + (y-rpos.y) * rdir.y + (z-rpos.z) * rdir.z) <= r + 1 then
					data[vi] = c_plating
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
