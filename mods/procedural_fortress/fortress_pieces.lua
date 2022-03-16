local c_ground = minetest.get_content_id("cicrev:dirt_with_grass")
local c_stone_brick = minetest.get_content_id("dungeon:stone_brick")
local n_ground = {name = "cicrev:dirt_with_grass"}
local n_stone_brick = {name = "dungeon:stone_brick"}
-- local n_stone_brick = {name = "cicrev:bark_dark"}

fortress_pieces = {}

local air_soft = {name = "air", prob = 0, force_place = false}
local air_hard = {name = "air", prob = 255, force_place = true}


local function get_block()
	local data = {}

	for n = 1, proc_fort.section_size*proc_fort.section_size*proc_fort.section_height do
		data[n] = n_stone_brick
	end

	return {
		size = {x = proc_fort.section_size, y = proc_fort.section_height, z = proc_fort.section_size},
		data = data,
	}
end
fortress_pieces.block = get_block()

local function get_block_ground()
	local data = {}

	local n = 1
	for z = 1, proc_fort.section_size do
		for y = 1, proc_fort.section_height do
			for x = 1, proc_fort.section_size do
				n = n + 1
				if y == proc_fort.section_height then
					data[n] = n_ground
				else
					data[n] = n_stone_brick
				end
			end
		end
	end

	return {
		size = {x = proc_fort.section_size, y = proc_fort.section_height, z = proc_fort.section_size},
		data = data,
	}
end
fortress_pieces.block_ground = get_block_ground()

local function get_wall_straight()
	local data = {}

	local n = 1
	for z = 1, proc_fort.section_size do
		for y = 1, proc_fort.section_height + 1 do
			for x = 1, proc_fort.section_size do
				n = n + 1
				if z == proc_fort.section_size and y >= proc_fort.section_height then
					data[n] = n_stone_brick
				else
					data[n] = air_soft
				end
			end
		end
	end

	return {
		size = {x = proc_fort.section_size, y = proc_fort.section_height + 1, z = proc_fort.section_size},
		data = data,
	}
end
fortress_pieces.wall_straight = get_wall_straight()

local function get_diagonal()
	local data = {}

	local n = 1
	for z = 1, proc_fort.section_size do
		for y = 1, proc_fort.section_height do
			for x = 1, proc_fort.section_size do
				n = n + 1
				if z <= proc_fort.section_size - (x - 1) then
					data[n] = n_stone_brick
				else
					data[n] = air_soft
				end
			end
		end
	end

	return {
		size = {x = proc_fort.section_size, y = proc_fort.section_height, z = proc_fort.section_size},
		data = data,
	}
end
fortress_pieces.diagonal = get_diagonal()

local function get_diagonal_ground()
	local data = {}

	local n = 1
	for z = 1, proc_fort.section_size do
		for y = 1, proc_fort.section_height do
			for x = 1, proc_fort.section_size do
				n = n + 1
				if z <= proc_fort.section_size - (x - 1) then
					if y < proc_fort.section_height then
						data[n] = n_stone_brick
					else
						data[n] = n_ground
					end
				else
					data[n] = air_soft
				end
			end
		end
	end

	return {
		size = {x = proc_fort.section_size, y = proc_fort.section_height, z = proc_fort.section_size},
		data = data,
	}
end
fortress_pieces.diagonal_ground = get_diagonal_ground()

local function get_diagonal_wall()
	local data = {}

	local n = 1
	for z = 1, proc_fort.section_size do
		for y = 1, proc_fort.section_height + 1 do
			for x = 1, proc_fort.section_size do
				n = n + 1
				if z == proc_fort.section_size - (x - 1) then
					data[n] = n_stone_brick
				else
					data[n] = air_soft
				end

			end
		end
	end

	return {
		size = {x = proc_fort.section_size, y = proc_fort.section_height + 1, z = proc_fort.section_size},
		data = data,
	}
end
fortress_pieces.diagonal_wall = get_diagonal_wall()

local function get_tunnel()
	local data = {}

	local middle = (proc_fort.section_size+1)/2
	local quater = proc_fort.section_size/4

	local n = 1
	for z = 1, proc_fort.section_size do
		for y = 1, proc_fort.section_height do
			for x = 1, proc_fort.section_size do
				n = n + 1
				if math.abs(x-middle) < quater and y <= proc_fort.section_height - 2 then
					data[n] = air_hard
				else
					data[n] = air_soft
				end

			end
		end
	end

	return {
		size = {x = proc_fort.section_size, y = proc_fort.section_height, z = proc_fort.section_size},
		data = data,
	}
end
if proc_fort.section_size >= 3 and proc_fort.section_height >= 4 then
	fortress_pieces.tunnel = get_tunnel()
end
local function get_bridge()
	local data = {}

	local n = 1
	for z = 1, proc_fort.section_size do
		for y = 1, proc_fort.section_height do
			for x = 1, proc_fort.section_size do
				n = n + 1
				if y == proc_fort.section_height-1 then
					data[n] = n_stone_brick
				elseif y == proc_fort.section_height then
					data[n] = n_ground
				else
					data[n] = air_soft
				end
			end
		end
	end

	return {
		size = {x = proc_fort.section_size, y = proc_fort.section_height, z = proc_fort.section_size},
		data = data,
	}
end
if proc_fort.section_size >= 3 and proc_fort.section_height >= 4 then
	fortress_pieces.bridge = get_bridge()
end
