trees = {}

function trees.get_valid_growth_positions(pos)
    local candidates = cicrev.get_touching_nodes(pos)
    for k, v in pairs(candidates) do
        if minetest.get_node(v).name ~= "air" then
            candidates[k] = nil
        end
        if #minetest.find_nodes_in_area(vector.add(v, 1), vector.add(v, -1), tree_1.trunk) > 3 then
            candidates[k] = nil
        end
    end
    return candidates
end

tree_1 = {
    trunk = "cicrev:log",
    leaves = "cicrev:leaves",
    leav_range = 4,
    energy = 10,
    branch_chance = 0.1,
    sidways_chance = 0.2,
}


minetest.register_craftitem("cicrev:axe_of_trees", {
    description = "axe of trees",
    inventory_image = "cicrev_axe_of_trees.png",
    wield_image = "cicrev_axe_of_trees.png",
    stack_max = 1,
    on_place = function(itemstack, placer, pointed_thing)
        local pos = pointed_thing.under
        local under_name = minetest.get_node(pos).name
        if under_name == "cicrev:dirt_with_grass" then
            local pos = pointed_thing.above
            minetest.set_node(pos, {name = tree_1.trunk, param2 = tree_1.energy})
        elseif under_name == tree_1.trunk then
            local energy = minetest.get_node(pos).param2
            if energy > 1 then --branching
                if math.random() < tree_1.branch_chance then
                    local r = math.random(3, 6)
                    v = cicrev.get_touching_nodes(pos)[r]
                    if minetest.get_node(v).name == "air" then
                        minetest.set_node(v, {name = tree_1.trunk, param2 = math.ceil(energy/2)})
                        minetest.set_node(pos, {name = tree_1.trunk, param2 = 0})
                    end
                    for _, v in pairs(trees.get_valid_growth_positions(pos)) do
                        --always branches to the same side
                            minetest.set_node(v, {name = tree_1.trunk, param2 = math.ceil(energy/2)})
                            minetest.set_node(pos, {name = tree_1.trunk, param2 = 0})
                            break
                    end
                elseif math.random() < tree_1.sidways_chance then --growing to the side
                    local posi = trees.get_valid_growth_positions(pos)
                    local g = cicrev.random_from_table(posi)
                        minetest.set_node(g, {name = tree_1.trunk, param2 = energy - 1})
                        minetest.set_node(pos, {name = tree_1.trunk, param2 = 0})
                else --just growing upwarsd, or to the side if there isn't enough space
                    for _, v in pairs(trees.get_valid_growth_positions(pos)) do
                        minetest.set_node(v, {name = tree_1.trunk, param2 = energy - 1})
                        minetest.set_node(pos, {name = tree_1.trunk, param2 = 0})
                        break
                    end
                end
            elseif energy == 1 then
                minetest.set_node(pos, {name = tree_1.trunk, param2 = 0})
                pos.y = pos.y + 1
                local airspace = cicrev.detect_cluster(pos, 99)
                for _, v in pairs(airspace) do
                    minetest.set_node(v, {name = tree_1.leaves, param2 = 1})
                end
                -- for _, v in pairs(cicrev.get_touching_nodes(pos)) do
                --     if minetest.get_node(v).name == "air" then
                --         minetest.set_node(v, {name = tree_1.leaves, param2 = 1})
                --         minetest.set_node(pos, {name = tree_1.trunk, param2 = 0})
                --     end
                -- end
            end
        elseif under_name == tree_1.leaves then
            local touching = cicrev.get_touching_nodes(pos)
            local min_distance = minetest.get_node(pos).param2
            for _, v in pairs(touching) do
                if minetest.get_node(v).name == tree_1.trunk then
                    minetest.set_node(pos, {name = tree_1.leaves, param2 = 1})
                    min_distance = 1
                elseif minetest.get_node(v).name == tree_1.leaves and
                   minetest.get_node(v).param2 < min_distance then
                       min_distance = minetest.get_node(v).param2
                       minetest.set_node(pos, {name = tree_1.leaves, param2 = min_distance + 1})
                end
            end
        end
    end,
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing and pointed_thing.under then --and minetest.get_node(pointed_thing.under).name == tree_1.trunk then
            local tree = cicrev.detect_cluster(pointed_thing.under, 50)
            for _, v in pairs(tree) do
                minetest.remove_node(v)
            end
        end
    end
})
