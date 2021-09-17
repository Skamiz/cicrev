fortress_pieces = {}

local air_soft = {name = "air", prob = 0, force_place = false}
local air_hard = {name = "air", prob = 255, force_place = true}

-- the following function spit out a schematic based on the provided dimensions

function fortress_pieces.wall_straight(node, section_size)
	local data = {}

	local n = 1
	for z = 1, section_size do
		for y = 1, 2 do
			for x = 1, section_size do
				n = n + 1
				if z == section_size then
					data[n] = node
				else
					data[n] = air_soft
				end
			end
		end
	end

	-- data[2*section_size*section_size] = air_hard

	return {
		size = {x = section_size, y = 2, z = section_size},
		data = data,
	}
end

function fortress_pieces.wall_diagonal(node, section_size, height)
	local data = {}

	local n = 1
	for z = 1, section_size do
		for y = 1, height do
			for x = 1, section_size do
				n = n + 1
				if z == section_size + 1 - x then
					data[n] = node
				elseif z > section_size + 1 - x then
					data[n] = air_hard
				else
					data[n] = air_soft
				end
			end
		end
	end

	-- data[2*section_size*section_size] = air_hard

	return {
		size = {x = section_size, y = height, z = section_size},
		data = data,
	}
end
