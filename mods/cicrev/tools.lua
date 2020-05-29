minetest.register_craftitem(":", {
    inventory_image = "hand.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        max_drop_level = 1,
        groupcaps = {
            hand = {maxlevel=0, times = { [1]=0.60, [2]=1.20, [3]=1.80 }
            },
        },
    },
})

minetest.register_tool("cicrev:creative_tool", {
	description = "Creative tool",
	inventory_image = "cicrev_creative_tool.png",
	range = 10,
	stack_max = 1,
	tool_capabilities = {
		full_punch_interval = 1,
		groupcaps = {
			hand = {maxlevel=0, times = {0.1, 0.1}},
			choppy = {maxlevel=0, times = {0.1}},
			cracky = {maxlevel=0, times = {0.1}},
		},
	},
})

minetest.register_tool("cicrev:flint_axe", {
	description = "Flint axe",
	inventory_image = "cicrev_flint_axe.png",
	stack_max = 1,
	tool_capabilities = {
		full_punch_interval = 1.5,
		max_drop_level = 1,
		groupcaps = {
			choppy = {times = {[1]=2.0}},
		},
	},
	on_place = strip_bark,
})
