local c_dirt = minetest.get_content_id("c_soil:soil_with_grass")
local c_stone = minetest.get_content_id("c_stone:granite")

minetest.set_mapgen_setting("water_level", "0", true)

local surface_level = 0 -- nodes at this level will be filled

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}



local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    math.randomseed(blockseed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)
				ni = ni + 1


				if y <= surface_level then
					data[vi] = c_dirt
				end
				if y <= surface_level - 1 then
					data[vi] = c_stone
				end
			end
		end
	end

	vm:set_data(data)
	-- vm:update_liquids()
	-- vm:calc_lighting()
	vm:write_to_map()
end)
