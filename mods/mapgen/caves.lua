local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

dofile(mod_path.."/cave_util.lua")

local c_air = minetest.CONTENT_AIR
local c_gair = minetest.get_content_id("lanterns:light_2")
local c_dirt = minetest.get_content_id("cicrev:loam")
local c_gneis = minetest.get_content_id("df_stones:gneiss")

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
	if maxp.y > 80 then return end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	vm:get_data(data)
	local density_data = get_cave_density_data(minp)
	if not density_data then return end

	local n = 1
	for i in area:iterp(minp, maxp) do
		if density_data[n] < 2.5 then
			data[i] = c_gair
		end
		n = n + 1
	end

	vm:set_data(data)
	vm:write_to_map()
end)
