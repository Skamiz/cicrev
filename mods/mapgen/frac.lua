-- local c_dirt = minetest.get_content_id("cicrev:dirt_with_grass")
local c_stone = minetest.get_content_id("df_stones:limestone")

minetest.set_mapgen_setting("water_level", "0", true)



local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local density_data = {}
local function reset_density(density_data)
	for i = 1, 80*80*80 do
		density_data[i] = 0
	end
end

local function is_in_middle(n, lim)
	local third = lim/3
	return (n > third and n <= (third*2))
end

local function is_air(a, levels)
	for n = levels, 1, -1 do
		local ex = math.pow(3, n)
		if is_in_middle(a%ex, ex) then
			return true
		end
	end
end

-- This apparently does not give enought data after all.
local function get_density_data(density_data, minp, maxp, levels)
	reset_density(density_data)

	local x_axis, y_axis, z_axis = {}, {}, {}
	for i = minp.x, maxp.x do
		if is_air(i, levels) then
			x_axis[i] = -1
		else
			x_axis[i] = 0
		end
	end
	for i = minp.y, maxp.y do
		if is_air(i, levels) then
			y_axis[i] = -1
		else
			y_axis[i] = 0
		end
	end
	for i = minp.z, maxp.z do
		if is_air(i, levels) then
			z_axis[i] = -1
		else
			z_axis[i] = 0
		end
	end

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				density_data[ni] = x_axis[x] + y_axis[y] + z_axis[z]
				ni = ni + 1
			end
		end
	end
	return density_data
end




local function is_stone(x, y, z, levels)
	for n = levels, 1, -1 do
		local ex = math.pow(3, n)
		local x_air, y_air, z_air = 0, 0, 0
		if is_in_middle(x%ex, ex) then x_air = 1 end
		if is_in_middle(y%ex, ex) then y_air = 1 end
		if is_in_middle(z%ex, ex) then z_air = 1 end
		-- if y%3 == 2 then y_air = 1 end
		-- if z%3 == 2 then z_air = 1 end
		if ((x_air + y_air + z_air) >= 2) then return false end
	end

	return true
end

local data = {}
minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)

	local density_data = get_density_data(density_data, minp, maxp, 3)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)

				if density_data[ni] > -3 then
					data[vi] = c_stone
				end

				ni = ni + 1
			end
		end
	end

	vm:set_data(data)
	-- vm:update_liquids()
	-- vm:calc_lighting()
	vm:write_to_map()
end)
