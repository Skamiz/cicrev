
local MODNAME = minetest.get_current_modname()

function register_slab(node_name)
    local node_def = minetest.registered_nodes[node_name]
    assert(node_def, "Trying to register a slab for " .. node_name .. ", which doesn't exist.")

    local slab_def = table.copy(node_def)
    slab_def.description = node_def.description .. " slab"
    slab_def.drawtype = "nodebox"
    slab_def.node_box = {
        type = "fixed",
        fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5}
    }
    slab_def.paramtype = "light"
    slab_def.paramtype2 = "facedir"
    slab_def.node_placement_prediction = ""
    slab_def.on_place = place_slab
    minetest.register_node(node_name .. "_slab", slab_def)

    minetest.register_craft({
        output = node_name .. "_slab",
        recipe = {
                {node_name, node_name},
            },
    })
end

function place_slab(itemstack, placer, pointed_thing)
    local exact = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
    if minetest.get_node(pointed_thing.above).name ~= "air" then return itemstack end
    if exact.y > pointed_thing.above.y then
        minetest.set_node(pointed_thing.above, {name = itemstack:get_name(), param2 = 22})
    else
        minetest.set_node(pointed_thing.above, {name = itemstack:get_name(), param2 = 0})
    end
    itemstack:take_item()
    return itemstack
end
