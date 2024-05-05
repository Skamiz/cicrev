-- given a pointed_thing determine which position, if any, a node would be placed in
function shapes.get_place_pos(pointed_thing)
	local node_under = minetest.get_node(pointed_thing.under)
	local def_under = minetest.registered_nodes[node_under.name]

	if def_under.buildable_to then
		return vector.copy(pointed_thing.under)
	end

	local node_above = minetest.get_node(pointed_thing.above)
	local def_above = minetest.registered_nodes[node_above.name]

	if def_above.buildable_to then
		return vector.copy(pointed_thing.above)
	end

	return nil
end

local function vector_components(v)
	local components = {}
	for axis, distance in pairs(v) do
		table.insert(components, {axis, distance})
	end
	table.sort(components, function(a, b)
		return math.abs(a[2]) > math.abs(b[2])
	end)
	return components
end

function shapes.place.pillar(itemstack, placer, pointed_thing)
		local pt = pointed_thing
		local param2 = 0
		if pt.above.x ~= pt.under.x then
			param2 = 12
		elseif pt.above.z ~= pt.under.z then
			param2 = 4
		end

	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end


local upside_down_stairs = {
	[0] = 20,
	[1] = 23,
	[2] = 22,
	[3] = 21,
}
function shapes.place.stair(itemstack, placer, pointed_thing)
	local placement_pos = shapes.get_place_pos(pointed_thing)
	if not placement_pos then return minetest.item_place(itemstack, placer, pointed_thing, nil) end

	local intersection_pos = shapes.pointed_pos(placer, nil, "exact")
	local relative_pos = intersection_pos - placement_pos

	local placement_normal = pointed_thing.under - pointed_thing.above
	local face_pos = vector.copy(relative_pos)

	for axis, distance in pairs(placement_normal) do
		if distance ~= 0 then
			face_pos[axis] = 0
		end
	end

	local param2 = 0
	if placement_normal.y == 0 and
	(math.abs(face_pos.x) > math.abs(face_pos.y) or
	math.abs(face_pos.z) > math.abs(face_pos.y)) then
		if relative_pos.x > 0 then
			param2 = relative_pos.z > 0 and 16 or 18
		else
			param2 = relative_pos.z > 0 and 12 or 14
		end
	else
		if math.abs(relative_pos.x) > math.abs(relative_pos.z) then
			param2 = relative_pos.x >= 0 and 1 or 3
		else
			param2 = relative_pos.z >= 0 and 0 or 2
		end
		if relative_pos.y > 0 then
			param2 = upside_down_stairs[param2]
		end

	end

	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end



local slab_direction = {
	["y-"] = 0,
	["z-"] = 4,
	["z+"] = 8,
	["x-"] = 12,
	["x+"] = 16,
	["y+"] = 20,
}
function shapes.place.slab(itemstack, placer, pointed_thing)
	local placement_pos = shapes.get_place_pos(pointed_thing)
	if not placement_pos then return minetest.item_place(itemstack, placer, pointed_thing, nil) end

	local intersection_pos = shapes.pointed_pos(placer, nil, "exact")
	local relative_pos = intersection_pos - placement_pos
	local components = vector_components(relative_pos)

	local main = 1
	if math.abs(components[2][2]) > shapes.orthogonal_slab_margin then
		main = 2
	end
	local param2 = slab_direction[components[main][1] .. (components[main][2] < 0 and "-" or "+")]

	return minetest.item_place(itemstack, placer, pointed_thing, param2)
end







-- function shapes.place.stair(itemstack, placer, pointed_thing)
-- 	-- local pos = shapes.pointed_pos(placer, diastance, "exact")
-- 	-- minetest.add_particle({pos = pos, texture = "cicrev_ash.png", expirationtime = 3,})
--
-- 	return minetest.rotate_and_place(itemstack, placer, pointed_thing)
-- 	-- return minetest.item_place(itemstack, placer, pointed_thing, param2)
-- end


-- function shapes.place.slab_simple(itemstack, placer, pointed_thing)
-- 	local intersection_pos = shapes.pointed_pos(placer, nil, "exact")
-- 	local pa, pu = pointed_thing.above, pointed_thing.under
-- 	local param2 = 0
-- 	if pa.y > pu.y then param2 = 0 end
-- 	if pa.y < pu.y then param2 = 20 end
-- 	if pa.x > pu.x then param2 = 12 end
-- 	if pa.x < pu.x then param2 = 16 end
-- 	if pa.z > pu.z then param2 = 4 end
-- 	if pa.z < pu.z then param2 = 8 end
--
-- 	return minetest.item_place(itemstack, placer, pointed_thing, param2)
-- end


-- local function place_slab_minecraft_like(itemstack, placer, pointed_thing)
-- 	local pos = shapes.pointed_pos(placer, diastance, "exact")
-- 	minetest.add_particle({pos = pos, texture = "cicrev_ash.png", expirationtime = 3,})
--
--     local exact = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
--     if minetest.get_node(pointed_thing.above).name ~= "air" then return itemstack end
--     if exact.y > pointed_thing.above.y then
--         minetest.set_node(pointed_thing.above, {name = itemstack:get_name(), param2 = 22})
--     else
--         minetest.set_node(pointed_thing.above, {name = itemstack:get_name(), param2 = 0})
--     end
--     itemstack:take_item()
--     return itemstack
-- end
