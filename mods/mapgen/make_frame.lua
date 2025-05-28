
minetest.register_alias("borderblock", "dungeon:stone_block")

local c_frame = minetest.get_content_id("borderblock")

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	if maxp.y > 80 then return end

	local t0 = minetest.get_us_time()
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)
	local vi


	for x = minp.x, maxp.x do
		vi = area:index(x, minp.y, minp.z)
		data[vi] = c_frame
	end
	for x = minp.x, maxp.x do
		vi = area:index(x, maxp.y, minp.z)
		data[vi] = c_frame
	end
	for x = minp.x, maxp.x do
		vi = area:index(x, minp.y, maxp.z)
		data[vi] = c_frame
	end
	for x = minp.x, maxp.x do
		vi = area:index(x, maxp.y, maxp.z)
		data[vi] = c_frame
	end

	for z = minp.z, maxp.z do
		vi = area:index(minp.x, minp.y, z)
		data[vi] = c_frame
	end
	for z = minp.z, maxp.z do
		vi = area:index(minp.x, maxp.y, z)
		data[vi] = c_frame
	end
	for z = minp.z, maxp.z do
		vi = area:index(maxp.x, minp.y, z)
		data[vi] = c_frame
	end
	for z = minp.z, maxp.z do
		vi = area:index(maxp.x, maxp.y, z)
		data[vi] = c_frame
	end

	for y = minp.y, maxp.y do
		vi = area:index(minp.x, y, minp.z)
		data[vi] = c_frame
	end
	for y = minp.y, maxp.y do
		vi = area:index(maxp.x, y, minp.z)
		data[vi] = c_frame
	end
	for y = minp.y, maxp.y do
		vi = area:index(minp.x, y, maxp.z)
		data[vi] = c_frame
	end
	for y = minp.y, maxp.y do
		vi = area:index(maxp.x, y, maxp.z)
		data[vi] = c_frame
	end


	vm:set_data(data)
	vm:write_to_map()
	print(((minetest.get_us_time() - t0) / 1000) .. " ms" )
	print(maxp)
	print(minp)
end)
