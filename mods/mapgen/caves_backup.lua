local mod_name = minetest.get_current_modname()
local mod_path = minetest.get_modpath(mod_name)

local cardinals = {"x", "y", "z"}

local offset_vectors = {
	{x = 80, y = 0, z = 0},
	{x = -80, y = 0, z = 0},
	{x = 0, y = 80, z = 0},
	{x = 0, y = -80, z = 0},
	{x = 0, y = 0, z = 80},
	{x = 0, y = 0, z = -80},
}

local schem = u.get_sphere_schematic(2.5, {name = "df_stones:gneiss", prob = 255})

local function is_in_area(minp, maxp, pos)
	return pos.x >= minp.x and pos.x <= maxp.x and
			pos.y >= minp.y and pos.y <= maxp.y and
			pos.z >= minp.z and pos.z <= maxp.z
end

local function get_random_points(minp, n)
	local points = {}
	math.randomseed(minetest.hash_node_position(minp))
	for i = 1, n do
		points[#points + 1] = {	x = minp.x + math.random(10, 70),
								y = minp.y + math.random(10, 70),
								z = minp.z + math.random(10, 70),}
	end
	return points
end

np_caves = {
        offset = 1.5,
        scale = 3,
        spread = {x = 300, y = 300, z = 300},
        seed = 9,
        octaves = 2,
        persist = 0.63,
        lacunarity = 2.0,
    }

local nobj_caves

minetest.register_on_generated(function(minp, maxp, blockseed)
	if maxp.y > 80 then return end

	nobj_caves = nobj_caves or minetest.get_perlin(np_caves)

	local vm = minetest.get_mapgen_object("voxelmanip")

	local points = get_random_points(minp, math.ceil(nobj_caves:get_3d(minp)))
	if #points == 0 then return end

	for i = 2 , #points do
		local line = make_line(points[i-1], points[i])
		for _, p in ipairs(line) do
	        if is_in_area(minp, maxp, p) then
	            minetest.place_schematic_on_vmanip(vm, p, schem, "0", replacement,
				 	true, "place_center_x, place_center_y, place_center_z")
	        end
	    end
	end

	for k, offset in pairs(offset_vectors) do
		local pos = vector.add(minp, offset)

		local other_points = get_random_points(pos, math.ceil(nobj_caves:get_3d(pos)))
		if not (#other_points == 0) then

			local p1, p2 = u.get_closeset_points(points, other_points)
			local replacements = {["df_stones:gneiss"] = "df_stones:obsidian"}

			if k % 2 == 1 then
				p1, p2 = p2, p1
				replacements = {["df_stones:gneiss"] = "df_stones:marble"}
			end

			local line = make_line(p1, p2)
	        for _, p in ipairs(line) do
	            if is_in_area(minp, maxp, p) then
					minetest.place_schematic_on_vmanip(vm, p, schem, "0", replacements,
					 	true, "place_center_x, place_center_y, place_center_z")
	            end
	        end
		end
	end

	vm:write_to_map()
end)
