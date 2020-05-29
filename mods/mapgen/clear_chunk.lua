-- sets whole chunk to air
-- usefull when testing changes in the mapgen

local data = {}
minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)

	for x = minp.x, maxp.x do
		for y = minp.y, maxp.y do
			for z = minp.z, maxp.z do
				local vi = area:index(x, y, z)
                data[vi] = minetest.CONTENT_AIR

			end
		end
	end

	vm:set_data(data)
	vm:write_to_map()
end)
