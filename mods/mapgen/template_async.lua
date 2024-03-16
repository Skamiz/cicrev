--[[
Template mapgen

]]

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local t0 = minetest.get_us_time()

	-- local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local vm = minetest.get_voxel_manip(minp, maxp)
	local emin, emax = vm:get_emerged_area()
	local data = vm:get_data()

	minetest.handle_async(function(minp, maxp, emin, emax, a_data)
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local side_lenght = (maxp.x - minp.x) + 1

		local c_stone = minetest.get_content_id("df_stones:andesite")

		-- for k, v in pairs(a_data) do
		-- 	a_data[k] = c_stone
		-- end

		for z = minp.z, maxp.z do
			for y = minp.y, maxp.y do
				for x = minp.x, maxp.x do
					-- voxel area index, takes into acount overgenerated mapblocks
					local vi = area:index(x, y, z)

					if y < 1 then
						a_data[vi] = c_stone
					end

				end
			end
		end
		return a_data
	end,
	function(data_returned)

		vm:set_data(data_returned)
		vm:write_to_map()
		print("Chunk generation time: " .. ((minetest.get_us_time() - t0) / 1000) .. " ms" )
	end,
	minp, maxp, emin, emax, data, vm)
end)
