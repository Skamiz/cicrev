
minetest.register_alias("borderblock", "cicrev:soil_with_grass")

local c_frame = minetest.get_content_id("borderblock")

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	if maxp.y > 80 then return end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)
	local vi

	for x = minp.x, minp.x + 79 do
		vi = area:index(x, minp.y, minp.z)
		data[vi] = c_frame
	end
	for x = minp.x, minp.x + 79 do
		vi = area:index(x, minp.y + 79, minp.z)
		data[vi] = c_frame
	end
	for x = minp.x, minp.x + 79 do
		vi = area:index(x, minp.y, minp.z + 79)
		data[vi] = c_frame
	end
	for x = minp.x, minp.x + 79 do
		vi = area:index(x, minp.y + 79, minp.z + 79)
		data[vi] = c_frame
	end

	for z = minp.z, minp.z + 79 do
		vi = area:index(minp.x, minp.y, z)
		data[vi] = c_frame
	end
	for z = minp.z, minp.z + 79 do
		vi = area:index(minp.x, minp.y + 79, z)
		data[vi] = c_frame
	end
	for z = minp.z, minp.z + 79 do
		vi = area:index(minp.x + 79, minp.y, z)
		data[vi] = c_frame
	end
	for z = minp.z, minp.z + 79 do
		vi = area:index(minp.x + 79, minp.y + 79, z)
		data[vi] = c_frame
	end

	for y = minp.y, minp.y + 79 do
		vi = area:index(minp.x, y, minp.z)
		data[vi] = c_frame
	end
	for y = minp.y, minp.y + 79 do
		vi = area:index(minp.x + 79, y, minp.z)
		data[vi] = c_frame
	end
	for y = minp.y, minp.y + 79 do
		vi = area:index(minp.x, y, minp.z + 79)
		data[vi] = c_frame
	end
	for y = minp.y, minp.y + 79 do
		vi = area:index(minp.x + 79, y, minp.z + 79)
		data[vi] = c_frame
	end


	vm:set_data(data)
	vm:write_to_map()
end)
