
local directions = {
	{x = 0, z = 1, rot = "0"},
	{x = 1, z = 0, rot = "90"},
	{x = 0, z = -1, rot = "180"},
	{x = -1, z = 0, rot = "270"},
}

function proc_fort.get_section_coordinates(pos)
	return {x = math.floor(pos.x/proc_fort.section_size),
		z = math.floor(pos.z/proc_fort.section_size),
		y = math.floor(pos.y/proc_fort.section_height),
	}
end

function proc_fort.get_section_pos(pos)
	return {x = pos.x - pos.x%proc_fort.section_size,
		z = pos.z - pos.z%proc_fort.section_size,
		y = pos.y - pos.y%proc_fort.section_height,
	}
end

function proc_fort.section_pos_to_coo(pos)
	return {x = pos.x/proc_fort.section_size,
		z = pos.z/proc_fort.section_size,
		y = pos.y/proc_fort.section_height,
	}
end

function proc_fort.section_coo_to_pos(pos)
	return {x = pos.x*proc_fort.section_size,
		z = pos.z*proc_fort.section_size,
		y = pos.y*proc_fort.section_height,
	}
end

function proc_fort.get_level_at(pos)
	local section_pos = proc_fort.get_section_pos(pos)
	return math.floor(proc_fort.nobj_fort:get_2d(section_pos))
end


local function is_traversible(x, y, z, data, area, dir)
	return  not data[area:index(x, y, z)] and
			data[area:index(x, y-1, z)]
end

local function is_diagonal(x, y, z, data, area, dir)
	return  not data[area:index(x + dir.x, y, z + dir.z)] and
			not data[area:index(x + dir.z, y, z - dir.x)] and
			data[area:index(x - dir.x, y, z - dir.z)] and
			data[area:index(x - dir.z, y, z + dir.x)]
end

local function is_tunnel(x, y, z, data, area, dir)
	return is_traversible(x + dir.x, y, z + dir.z, data, area, dir) and
			is_traversible(x - dir.x, y, z - dir.z, data, area, dir) and
			(not is_traversible(x + dir.x + dir.z, y, z + dir.z - dir.x, data, area, dir) or
			not is_traversible(x + dir.z, y, z - dir.x, data, area, dir) or
			not is_traversible(x - dir.x + dir.z, y, z - dir.z - dir.x, data, area, dir)) and
			(not is_traversible(x - dir.x - dir.z, y, z - dir.z + dir.x, data, area, dir) or
			not is_traversible(x - dir.z, y, z + dir.x, data, area, dir) or
			not is_traversible(x + dir.x - dir.z, y, z + dir.z + dir.x, data, area, dir))
end


function proc_fort.generate_data(area, minsc, maxsc)
	local data = {}

	-- first we establish if there is anything in the section
	for z = minsc.z-2, maxsc.z+2 do
		for x = minsc.x-2, maxsc.x+2 do
			local level = proc_fort.get_level_at(proc_fort.section_coo_to_pos({x = x, z = z, y = 0}))
			for y = minsc.y-2, maxsc.y+2 do
				if y < level then
					data[area:index(x, y, z)] = {}
				end
			end
		end
	end

	if fortress_pieces.bridge then
		for i in area:iterp(minsc, maxsc) do
			if not data[i] then
				local coo = area:position(i)
				for r, dir in ipairs(directions) do
					if is_tunnel(coo.x, coo.y+1, coo.z, data, area, dir) then
						data[i] = {}
						table.insert(data[i], {schem = fortress_pieces.bridge, rot = dir.rot})

						local dir2 = directions[(r%4) + 1]
						if not data[area:index(coo.x + dir2.x, coo.y, coo.z + dir2.z)] then
							table.insert(data[i], {schem = fortress_pieces.wall_straight, rot = dir2.rot})
						end
						local dir4 = directions[(((((r%4) + 1)%4) + 1)%4) + 1]
						if not data[area:index(coo.x + dir4.x, coo.y, coo.z + dir4.z)] then
							table.insert(data[i], {schem = fortress_pieces.wall_straight, rot = dir4.rot})
						end
					end
				end
			end
		end
	end

	-- diagonals
	for z = minsc.z, maxsc.z do
		for x = minsc.x, maxsc.x do
			for r, dir in ipairs(directions) do
				local diagonal = true
				for y = maxsc.y, minsc.y, -1 do
					if data[area:index(x, y, z)] then
						if diagonal and is_diagonal(x, y, z, data, area, dir) then
							table.insert(data[area:index(x, y, z)], {schem = fortress_pieces.diagonal, rot = dir.rot})

							if not data[area:index(x, y + 1, z)] then
								table.insert(data[area:index(x, y, z)], {schem = fortress_pieces.diagonal_ground, rot = dir.rot})
								table.insert(data[area:index(x, y, z)], {schem = fortress_pieces.diagonal_wall, rot = dir.rot})
							end

							if not is_diagonal(x, y-1, z, data, area, dir) then
								table.insert(data[area:index(x, y-1, z)], {schem = fortress_pieces.block_ground})

								if not data[area:index(x + dir.x, y-1, z + dir.z)] then
									table.insert(data[area:index(x, y-1, z)], {schem = fortress_pieces.wall_straight, rot = dir.rot})
								end

								local dir2 = directions[(r%4) + 1]
								if not data[area:index(x + dir2.x, y-1, z + dir2.z)] then
									table.insert(data[area:index(x, y-1, z)], {schem = fortress_pieces.wall_straight, rot = dir2.rot})
								end
							end
						else
							diagonal = false
						end
					end
				end
			end
		end
	end

	for z = minsc.z, maxsc.z do
		for y = minsc.y, maxsc.y do
			for x = minsc.x, maxsc.x do
				if data[area:index(x, y, z)] and not data[area:index(x, y, z)][1] then
					-- place ground
					table.insert(data[area:index(x, y, z)], {schem = fortress_pieces.block})

					-- if nothings above, place ground and walls
					if not data[area:index(x, y+1, z)] then
						table.insert(data[area:index(x, y, z)], {schem = fortress_pieces.block_ground})

						for _, dir in ipairs(directions) do
							if not data[area:index(x + dir.x, y, z + dir.z)] then
								table.insert(data[area:index(x, y, z)], {schem = fortress_pieces.wall_straight, rot = dir.rot})
							end
						end
					end

					if fortress_pieces.tunnel then
						for r, dir in ipairs(directions) do
							if is_tunnel(x, y, z, data, area, dir) then
								table.insert(data[area:index(x, y, z)], {schem = fortress_pieces.tunnel, rot = dir.rot})
							end
						end
					end

				end
			end
		end
	end

	return data
end
