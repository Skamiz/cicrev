local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
dofile(modpath.."/fortress_pieces.lua")

local c_ground = minetest.get_content_id("cicrev:dirt_with_grass")
local c_stone_brick = minetest.get_content_id("dungeon:stone_brick")
local c_stone_block = minetest.get_content_id("dungeon:stone_block")
local c_water = minetest.get_content_id("cicrev:water_source")

minetest.set_mapgen_setting("water_level", "0", true)
local section_height = 5 -- height per level
local section_size = 10 -- has to evenly dive 80

local section_per_mapchunk = 80/section_size


local margin = 2 -- how much extra fortress data should be generated so that it can be used to determine changes dependent on nighbors
local fortress_data = {}
local fortress_area = VoxelArea:new({MinEdge={x=1 - margin, y=1, z=1 - margin}, MaxEdge={x=section_per_mapchunk + margin, y=1, z=section_per_mapchunk + margin}})



local function pos_to_section_pos(x, z)

	if type(x) == "table" then
		x, z = x.x, x.z
	end

	x = math.floor(x / section_size)
	z = math.floor(z / section_size)

	return x, z
end




-- schematics, see 'fortress_pieces.lua'
local wall_straight = fortress_pieces.wall_straight({name = "dungeon:stone_brick", force_place = true}, section_size)
local wall_diagonal = fortress_pieces.wall_diagonal({name = "dungeon:stone_brick", force_place = true}, section_size, section_height + 1)
-- local tower = fortress_pieces.tower({name = "dungeon:stone_brick", force_place = true}, section_size, section_height + 1)

local cardinal_directions = {
	{x = 0, z = 1, rot = "0"},
	{x = 1, z = 0, rot = "90"},
	{x = 0, z = -1, rot = "180"},
	{x = -1, z = 0, rot = "270"},
}

-- noise parameters

np_2d = {
        offset = 0,
        scale = 5,	-- affects how many levels total there are
        spread = {x = 4, y = 4, z = 40}, -- affects how spread out the overall structure is
        seed = 0,
        octaves = 1,
        persist = 1,
        lacunarity = 1.0,
		flags = "noeased,absvalue",
}


local nobj_2d = noise_handler.get_noise_object(np_2d)

-- takes noise at position and returns floored value. which results in the steps
local function pos_to_level(x,z)
	local pos = {x = math.floor(x/section_size) * section_size, z = math.floor(z/section_size) * section_size}
	local level = nobj_2d:get_2d(pos)
	return math.floor(level)
end


local function populate_fortress_data(minp)
	-- minetest.chat_send_all("new section")

	-- local fi = 1
	for z = 1-margin, section_per_mapchunk+margin do
		for x = 1-margin, section_per_mapchunk+margin do

			local ai = fortress_area:index(x, 1, z)

			-- minetest.chat_send_all("ai is: " .. ai)


			fortress_data[ai] = {
				 top_level = pos_to_level(minp.x + (x-1) * section_size, minp.z + (z-1) * section_size)
			}
			-- fi = fi + 1
		end
	end
end



local diagonal_pattern = {
	{"?", "<", "?"},
	{">=", "?", "<"},
	{"?", ">=", "?"},
}

local function find_pattern(x, z, pattern)
	local sidelen = #pattern
	local r = sidlen / 2 + 0.5

	local current_height = fortress_data[fortress_area:index(x, 1, z)]

	for _, v in pairs(cardinal_directions) do
		local pattern_foud = false

		for xd = 1, sidelen do
			for zd = 1, sidelen do



			end
		end

	end
end




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
		vm_tools.place_block(c_stone_brick, minp, maxp)
		vm:set_data(data)
		vm:write_to_map()
		return
	end
	if minp.y > 80 then return end

    -- math.randomseed(blockseed)
	populate_fortress_data(minp)

	local fi = 1
	for z = minp.z, maxp.z, section_size do
		for x = minp.x, maxp.x, section_size do
			local level = pos_to_level(x,z)
			local height = level * section_height
			if height < minp.y then return end

			-- fill up entire section up to height
			if minp.y <= height then
				vm_tools.place_block(c_stone_brick, x, minp.y, z, x + section_size - 1, height, z + section_size - 1)
			end
			-- place a layer of the ground node at the top
			if height > minp.y and height < maxp.y then
				vm_tools.place_block(c_ground, x, height, z, x + section_size - 1, height, z + section_size - 1)
			end

			-- local section_x = (x-minp.x) / section_size + 1
			-- local section_z = (z-minp.z) / section_size + 1
			--
			-- local ai = fortress_area:index(section_x, 1, section_z)
			-- -- minetest.chat_send_all("ai is: " .. ai)
			--
			--
			-- if height > minp.y and height < maxp.y then
			-- 	vm_tools.place_block(c_ground, x+1, fortress_data[ai].top_level*section_height + 3, z+1, x + section_size - 2, fortress_data[ai].top_level*section_height + 3, z + section_size - 2)
			-- end
			--
			-- fi = fi + 1
		end
	end


	vm:set_data(data)

	-- the main advantage of schematics is that they have builtin suport for rotation

	for z = minp.z, maxp.z, section_size do
		for x = minp.x, maxp.x, section_size do
			local level = pos_to_level(x,z)
			local height = level * section_height

			for _, dir in pairs(cardinal_directions) do
				-- place basic wall
				if level > pos_to_level(x + (dir.x * section_size), z + (dir.z * section_size)) then
					minetest.place_schematic_on_vmanip(vm, {x = x, y = height, z = z}, wall_straight, dir.rot)
				end
			end

			for _, dir in pairs(cardinal_directions) do
				-- place diagonal wall
				if level > pos_to_level(x + (dir.x * section_size), z + (dir.z * section_size)) and
						level > pos_to_level(x + (dir.z * section_size), z + (-dir.x * section_size)) and
						level <= pos_to_level(x + (-dir.x * section_size), z + (-dir.z * section_size)) and
						level <= pos_to_level(x + (-dir.z * section_size), z + (dir.x * section_size)) then
					minetest.place_schematic_on_vmanip(vm, {x = x, y = height + 1 - section_height, z = z}, wall_diagonal, dir.rot)
				end
			end

		end
	end

	vm:write_to_map()
end)



minetest.register_craftitem("mapgen:fortress_wand", {
	description = "Fortress Wand",
	inventory_image = "castle_wand.png",
	wield_image = "castle_wand.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)

	end,
	on_secondary_use = function(itemstack, user, pointed_thing)

	end,
	on_use = function(itemstack, user, pointed_thing)
		local pos = user:get_pos()
		local x, z = pos_to_section_pos(pos)
		local section_pos = {x = x, y = 0, z = z}
		minetest.chat_send_all("At: " .. minetest.pos_to_string(vector.round(pos)) .. " the height level is: " .. pos_to_level(pos.x, pos.y))
	end,
})
