minetest.register_craft({
    output = "cicrev:planks_dark 4",
    recipe = {
            {'cicrev:log_dark'},
        },
})

minetest.register_craft({
    output = "cicrev:stick 2",
    recipe = {
            {'group:planks'},
        },
})

minetest.register_craft({
    output = "cicrev:flint_axe",
    recipe = {
            {'cicrev:flint', 'cicrev:flint', ''},
            {'cicrev:flint', 'cicrev:stick', ''},
            {'', 'cicrev:stick', ''},
        },
})

minetest.register_craft({
    output = "cicrev:crate",
    recipe = {
            {'group:planks', 'group:planks', 'group:planks'},
            {'group:planks', '', 			 'group:planks'},
            {'group:planks', 'group:planks', 'group:planks'},
        },
})

minetest.register_craft({
    output = "cicrev:grass_rope",
    recipe = {
            {'', '', 'cicrev:grass'},
            {'', 'cicrev:grass', 'cicrev:grass'},
            {'cicrev:grass', 'cicrev:grass', ''},
        },
})

minetest.register_craft({
    output = "cicrev:ladder",
    recipe = {
            {'cicrev:stick', 'cicrev:grass_rope', 'cicrev:stick'},
            {'cicrev:stick', 'cicrev:stick', 'cicrev:stick'},
            {'cicrev:stick', 'cicrev:grass_rope', 'cicrev:stick'},
        },
})

minetest.register_craft({
    output = "cicrev:flint",
    recipe = {
            {'cicrev:gravel'},
        },
})
