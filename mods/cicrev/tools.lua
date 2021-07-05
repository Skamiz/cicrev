minetest.register_craftitem(":", {
    inventory_image = "hand.png",
    tool_capabilities = {
        full_punch_interval = 1.5,
        groupcaps = {
            hand = {maxlevel=0, times = { [1]=0.60, [2]=1.20, [3]=5.00 }
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
			hand = {maxlevel=0, times = {0.2, 0.2}},
			choppy = {maxlevel=0, times = {0.2}},
			cracky = {maxlevel=0, times = {0.2}},
			crumbly = {maxlevel=0, times = {0.2}},
		},
	},
})

minetest.register_tool("cicrev:digging_stick", {
	description = "Digging Stick",
	inventory_image = "cicrev_digging_stick.png",
	tool_capabilities = {
		full_punch_interval = 1.0,
		groupcaps = {
			crumbly = {times = {[1] = 3.00}, uses = 50, maxlevel = 0},
		},
	},
	-- groups = {},
})

minetest.register_tool("cicrev:knife_flint", {
	description = "Flint knife",
	inventory_image = "cicrev_knife_flint.png",
	stack_max = 1,
	tool_capabilities = {
		full_punch_interval = 1.2,
		groupcaps = {
			choppy = {times = {[1]=7.0}, uses = 20, maxlevel = 0},
		},
	},
	on_place = strip_bark,
})

minetest.register_tool("cicrev:axe_flint", {
	description = "Flint axe",
	inventory_image = "cicrev_flint_axe.png",
	stack_max = 1,
	tool_capabilities = {
		full_punch_interval = 1.5,
		groupcaps = {
			choppy = {times = {[1]=2.0}, uses = 50, maxlevel = 0},
		},
	},
	on_place = strip_bark,
})

minetest.register_tool("cicrev:mallet_wood", {
	description = "Wooden Mallet",
	inventory_image = "cicrev_mallet_wood.png",
	tool_capabilities = {
		full_punch_interval = 2,
		groupcaps={
			cracky = {times = {[1] = 10.00}, uses = 20, maxlevel = 0},
		},
	},
	groups = {pickaxe = 1},
})
