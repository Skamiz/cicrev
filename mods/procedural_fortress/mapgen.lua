local c_ground = minetest.get_content_id("df_stones:dacite")
local c_stone_brick = minetest.get_content_id("dungeon:stone_brick")
local c_stone_block = minetest.get_content_id("dungeon:stone_block")
local c_water = minetest.get_content_id("cicrev:water_source")
local c_bedrock = minetest.get_content_id("df_stones:obsidian")



local data = {}

-- voxel manip helper functions
local vm_tools = {}
vm_tools.data = data

-- helper function for arbitrarily placing blocks of nodes
function vm_tools.place_block(node, min_x, min_y, min_z, max_x, max_y, max_z)

	if type(min_x) == "table" and type(min_y) == "table" then
		min_x, min_y, min_z, max_x, max_y, max_z = min_x.x, min_x.y, min_x.z, min_y.x, min_y.y, min_y.z
	end

	if min_x > max_x then min_x, max_x = max_x, min_x end
	if min_y > max_y then min_y, max_y = max_y, min_y end
	if min_z > max_z then min_z, max_z = max_z, min_z end


	for z = min_z, max_z do
		for y = min_y, max_y do
			for x = min_x, max_x do
				if vm_tools.area:contains(x, y, z) then
					vm_tools.data[vm_tools.area:index(x, y, z)] = node
				else
					minetest.chat_send_all("Tring to write data outside of curently generated area, at: " .. x .. "|" .. y .. "|" .. z)
					return
				end
			end
		end
	end
end

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)
	vm_tools.area = area

	-- minetest.chat_send_all("Minp: " .. minetest.pos_to_string(minp) .. " | Maxp: " .. minetest.pos_to_string(maxp))
	-- minetest.chat_send_all("Minp X: " .. minp.x/section_size .. " | Minp Z: " .. minp.z/section_size)

	if maxp.y < 0 then
		vm_tools.place_block(c_bedrock, minp, maxp)
		vm:set_data(data)
		vm:write_to_map()
		return
	end
	if minp.y > 80 then return end


	local minsc = proc_fort.get_section_coordinates(minp)
	local maxsc = proc_fort.get_section_coordinates(maxp)
	local fortress_area = VoxelArea:new({MinEdge=vector.add(minsc, -2), MaxEdge=vector.add(maxsc, 2)})
	local fortress_data = proc_fort.generate_data(fortress_area, minsc, maxsc)

	vm:set_data(data)

	for i in fortress_area:iterp(minsc, maxsc) do
		if fortress_data[i] then
			local pos = proc_fort.section_coo_to_pos(fortress_area:position(i))
			for _, v in ipairs(fortress_data[i]) do
				minetest.place_schematic_on_vmanip(vm, pos, v.schem, v.rot)
			end
		end
	end

	vm:write_to_map()
end)
