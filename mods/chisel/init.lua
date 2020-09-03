
local MODNAME = minetest.get_current_modname()
dofile(minetest.get_modpath(MODNAME).."/nodebox_definitions.lua")

local chiseable_nodes = {}

function make_chiseable(node_name)
    local node_def = minetest.registered_nodes[node_name]
    assert(node_def, "Trying to register a chiseable for " .. node_name .. ", which doesn't exist.")

    node_def.groups.chiseable = 1
     -- for whatever fucked up reason it can't be assingned direcly like with the group
    minetest.override_item(node_name, {_matrix = {1, 1, 1, 1, 1, 1, 1, 1}})
    minetest.override_item(node_name, {_missing = 0})
    minetest.override_item(node_name, {_original = node_name})

    local chis_def = table.copy(node_def)
    chis_def.description = "Chiseled " .. node_def.description
    chis_def.drawtype = "nodebox"
    chis_def.paramtype = "light"
    chis_def.paramtype2 = "facedir"
    chis_def.groups.not_in_creative_inventory = 1
    chis_def.drop = ""
    chis_def.node_placement_prediction = ""
    chis_def._original = node_name
	local tiles = chis_def.tiles

	for k, tile in pairs(tiles) do
		if type(tile) == "string" then
			tiles[k] = {name = tile, align_style = "world"}
		else
			tile.align_style = "world"
		end
	end

    for m, missing in pairs(nodeboxes) do
        for n, box_def in pairs(missing) do
            local def_def = table.copy(chis_def)
            def_def.node_box = box_def
            def_def._matrix = box_def.matrix
            def_def._missing = m
            minetest.register_node(":" .. node_name .. "_chiseled_" .. m .. "_" .. n, def_def)
        end
    end
end


local offsets = {
    {x = -0.5, y = -0.5, z = -0.5},
    {x = -0.5, y = -0.5, z = 0.5},
    {x = -0.5, y = 0.5, z = -0.5},
    {x = -0.5, y = 0.5, z = 0.5},
    {x = 0.5, y = -0.5, z = -0.5},
    {x = 0.5, y = -0.5, z = 0.5},
    {x = 0.5, y = 0.5, z = -0.5},
    {x = 0.5, y = 0.5, z = 0.5},
}


local function rotate_matrix_along_X(matrix)
    matrix[1], matrix[2], matrix[3], matrix[4], matrix[5], matrix[6], matrix[7], matrix[8] =
    matrix[2], matrix[4], matrix[1], matrix[3], matrix[6], matrix[8], matrix[5], matrix[7]
    return matrix
end
local function rotate_matrix_against_X(matrix)
    rotate_matrix_along_X(matrix)
    rotate_matrix_along_X(matrix)
    rotate_matrix_along_X(matrix)
    return matrix
end
local function rotate_matrix_along_Y(matrix)
    matrix[1], matrix[2], matrix[3], matrix[4], matrix[5], matrix[6], matrix[7], matrix[8] =
    matrix[5], matrix[1], matrix[7], matrix[3], matrix[6], matrix[2], matrix[8], matrix[4]
    return matrix
end
local function rotate_matrix_against_Y(matrix)
    rotate_matrix_along_Y(matrix)
    rotate_matrix_along_Y(matrix)
    rotate_matrix_along_Y(matrix)
    return matrix
end
local function rotate_matrix_along_Z(matrix)
    matrix[1], matrix[2], matrix[3], matrix[4], matrix[5], matrix[6], matrix[7], matrix[8] =
    matrix[3], matrix[4], matrix[7], matrix[8], matrix[1], matrix[2], matrix[5], matrix[6]
    return matrix
end
local function rotate_matrix_against_Z(matrix)
    rotate_matrix_along_Z(matrix)
    rotate_matrix_along_Z(matrix)
    rotate_matrix_along_Z(matrix)
    return matrix
end

local function rotate_matrix_to_param(matrix, param2)
    local axis = math.floor(param2/4)
    if axis == 0 then
        for i = 0, (param2 + 3) % 4 do
            matrix = rotate_matrix_along_Y(matrix)
        end
    elseif axis == 1 then
        matrix = rotate_matrix_along_X(matrix)
        for i = 0, (param2 + 3) % 4 do
            matrix = rotate_matrix_along_Z(matrix)
        end
    elseif axis == 2 then
        matrix = rotate_matrix_against_X(matrix)
        for i = 0, (param2 + 3) % 4 do
            matrix = rotate_matrix_against_Z(matrix)
        end
    elseif axis == 3 then
        matrix = rotate_matrix_against_Z(matrix)
        for i = 0, (param2 + 3) % 4 do
            matrix = rotate_matrix_along_X(matrix)
        end
    elseif axis == 4 then
        matrix = rotate_matrix_along_Z(matrix)
        for i = 0, (param2 + 3) % 4 do
            matrix = rotate_matrix_against_X(matrix)
        end
    elseif axis == 5 then
        matrix = rotate_matrix_against_Z(matrix)
        matrix = rotate_matrix_against_Z(matrix)
        for i = 0, (param2 + 3) % 4 do
            matrix = rotate_matrix_against_Y(matrix)
        end
    end
    return matrix
end

local function matrix_equality(matrix_a, matrix_b)
    local same = true
    for i = 1, 8 do
        if matrix_a[i] ~= matrix_b[i] then same = false end
    end
    return same
end

-- returns the first position on which look direction vector intersects something or nil
-- doesn't detect objects since the result would always be the eye_pos
local function pointing_pos(player, distance, liquids)
    local eye_height = player:get_properties().eye_height
    local eye_pos = player:get_pos()
        eye_pos.y = eye_pos.y + eye_height
    local look_dir = player:get_look_dir()
    local ray_end = vector.multiply(look_dir, distance or 5)
        ray_end = vector.add(eye_pos, ray_end)

    local ray = minetest.raycast(eye_pos, ray_end, false, liquids)
    return ray:next().intersection_point
end

-- TODO this needs SO much refactoring to be legible

minetest.register_craftitem("chisel:chisel", {
    description = "Chisel",
    inventory_image = "chisel_chisel.png",
    stack_max = 1,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type ~= "node" then return end
        local node = minetest.get_node(pointed_thing.under)
        local node_def = minetest.registered_nodes[node.name]
        if not node_def.groups.chiseable then return end

        if node_def._missing == 7 then
            minetest.remove_node(pointed_thing.under)
            return
        end
        local original_matrix = table.copy(node_def._matrix) or {1, 1, 1, 1, 1, 1, 1, 1}
        original_matrix = rotate_matrix_to_param(original_matrix, node.param2)


        local direction = user:get_look_dir()
        direction = vector.multiply(direction, 0.0001)

        local intersection = pointing_pos(user)
        intersection = vector.add(intersection, direction)

        local relative = vector.subtract(intersection, pointed_thing.under)

        local chisel_location = 1
        if relative.z >= 0 then chisel_location = chisel_location + 1 end
        if relative.y >= 0 then chisel_location = chisel_location + 2 end
        if relative.x >= 0 then chisel_location = chisel_location + 4 end
        original_matrix[chisel_location] = 0


        for k, v in pairs(nodeboxes[node_def._missing + 1]) do
            for i = 0, 23 do
                local new_matrix = table.copy(v.matrix)
                new_matrix = rotate_matrix_to_param(new_matrix, i)
                if matrix_equality(new_matrix, original_matrix) then
                    minetest.set_node(pointed_thing.under, {name = node_def._original .. "_chiseled_" .. node_def._missing + 1 .. "_" .. k, param2 = i})
                end
            end
        end

    end,

    on_place = function(itemstack, placer, pointed_thing)
        local node = minetest.get_node(pointed_thing.under)
        local node_def = minetest.registered_nodes[node.name]
        if node_def.groups.chiseable then
            minetest.chat_send_player(placer:get_player_name(), "This node is chiseable.")
            if node_def.node_box and node_def.node_box.matrix then
                for k, v in pairs(offsets) do
                    local particle_pos = vector.add(pointed_thing.under, v)
                    local matrix = rotate_matrix_to_param(table.copy(node_def.node_box.matrix), node.param2)
                    local texture = "chisel_" .. matrix[k] .. ".png"
                    minetest.add_particle({pos = particle_pos, texture = texture, expirationtime = 3,})
                end
            end
        else
            minetest.chat_send_player(placer:get_player_name(), "This node is not chiseable.")
        end
    end
})
