local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local c_wall = minetest.get_content_id("dungeon:stone_brick")
local c_block = minetest.get_content_id("dungeon:stone_block")
local c_gound = minetest.get_content_id("dungeon:floor")


local function check_area(tiles, area, x, z, width, height)
	for i in area:iter(x-1, 1, z-1, x + width, 1, z + height) do
		if tiles[i] == "air"  then
			return false
		end
	end
	for i in area:iter(x, 1, z, x + width - 1, 1, z + height - 1) do
		if tiles[i] == "block"  then
			return false
		end
	end
	return true
end

local function try_place_room(tiles, area, x, z)
	-- min room size
	local width, height = 2, 2

	-- starting area is no good
	if not check_area(tiles, area, x, z, width, height) then return false end

	-- try to expand room
	for i = 1, 4 do
		if check_area(tiles, area, x, z, width + 1, height) and math.random() < 0.7 then
			width = width + 1
		end
		if check_area(tiles, area, x, z, width, height + 1) and math.random() < 0.7 then
			height = height + 1
		end
	end

	for i in area:iter(x, 1, z, x + width - 1, 1, z + height - 1) do
		tiles[i] = "air"
	end
	return true
end

local function generate_dungeon(tiles_x, tiles_z)
	local tiles = {}
	local n = 0
	for z = 1, tiles_z do
		for x = 1, tiles_x do
			n = n + 1
			if x == 1 or x == tiles_x or z == 1 or z == tiles_z then
				tiles[n] = "block"
			else
				tiles[n] = "wall"
			end
		end
	end

	local area = VoxelArea:new({MinEdge = vector.new(1, 1, 1), MaxEdge = vector.new(tiles_x, 1, tiles_z)})

	local n = 0
	while n < 5 do
		local x = math.random(2, 22)
		local y = math.random(2, 22)

		if try_place_room(tiles, area, x, y) then
			n = n + 1
		end
	end

	local n = 0
	for z = 1, tiles_z do
		for x = 1, tiles_x do
			n = n + 1
			if tiles[n] == "wall"  and math.random() < 0.7 then
				try_place_room(tiles, area, x, z)
			end
		end
	end

	return tiles
end





minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- necesary, otherwise it breaks things

--noise parameters
np_3d = {
    offset = 0,
    scale = 10,
    spread = {x = 10, y = 10, z = 10},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
}

np_2d = {
    offset = 0,
    scale = 10,
    spread = {x = 40, y = 40, z = 40},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
	flags = "noeased",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, chunkseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    -- local nvals_3d = nobj_3d:get_3d_map_flat(minp)
    -- local nvals_2d = nobj_2d:get_2d_map_flat(minp)

	local tiles_x = (((maxp.x - maxp.x % 3) - (minp.x - minp.x % 3)) / 3) + 1

	local tiles_z = (((maxp.z - maxp.z % 3) - (minp.z - minp.z % 3)) / 3) + 1

	minetest.chat_send_all("Chunk tiles: X " .. tiles_x .. " | Y " .. tiles_z)

    math.randomseed(chunkseed)

	local dungeon = generate_dungeon(tiles_x, tiles_z, seed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)
				ni = ni + 1
				-- local nv_3d = nvals_3d[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]
                -- local nv_2d = nvals_2d[(z-minp.z) * 80 + (x-minp.x) + 1]

				-- if y < 5 then
				-- 	if x == maxp.x - maxp.x % 3 and z == maxp.z - maxp.z % 3 then
				-- 		data[vi] = c_wall
				-- 	end
				-- 	if x == minp.x - minp.x % 3 and z == minp.z - minp.z % 3 then
				-- 		data[vi] = c_wall
				-- 	end
				-- end

				if y < 0 then
					data[vi] = c_gound
				end
			end
		end
	end

	vm:set_data(data)
	local n = 0
	for z = 1, tiles_z do
		for x = 1, tiles_x do
			n = n + 1
			if dungeon[n] then
				minetest.place_schematic_on_vmanip(vm,
						{x = (minp.x - minp.x % 3) + 1 + 3 * (x - 1), y = 1, z = (minp.z - minp.z % 3) + 1 + 3 * (z - 1)},
						modpath .. "/schems/" .. dungeon[n] .. ".mts",
						rotation,
						replacement,
						force_placement,
						"place_center_x, place_center_y, place_center_z")
			end
		end
	end

    -- minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
end)
