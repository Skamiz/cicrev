-- TODO: a setting, even if just in code, that can turn of tool wear
minetest.register_craftitem("cicrev:hand", {
	description = "Hand",
    inventory_image = "cicrev_hand.png",
	range = 5,
    tool_capabilities = {
        full_punch_interval = 1.5,
        groupcaps = {
            hand = {maxlevel=0, times = {[1] = 0.60, [2] = 1.20, [3] = 5.00}},
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
			everything = {maxlevel = 0, times = {0.2, 0.2}},
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
	on_place = cicrev.strip_bark,
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
	on_place = cicrev.strip_bark,
})

minetest.register_tool("cicrev:mallet_wood", {
	description = "Wooden Mallet",
	inventory_image = "cicrev_mallet_wood.png",
	tool_capabilities = {
		full_punch_interval = 5, -- no effect on dig swing speed
		groupcaps={
			cracky = {times = {[1] = 15.00}, uses = 20, maxlevel = 0},
		},
	},
	groups = {pickaxe = 1},
})
minetest.register_tool("cicrev:pickaxe_copper", {
	description = "Copper Pickaxe",
	inventory_image = "cicrev_pickaxe_copper.png",
	tool_capabilities = {
		groupcaps={
			cracky = {times = {[1] = 5.00}, uses = 30, maxlevel = 0},
		},
	},
	groups = {pickaxe = 1},
})

minetest.register_tool("cicrev:fire_stones", {
	description = "Fire Stones",
	inventory_image = "cicrev_fire_stones.png",
	on_place = function(itemstack, placer, pointed_thing)
		if not pointed_thing then return end
		local pos = pointed_thing.under
		if minetest.get_node(pos).name == "cicrev:campfire" then
			minetest.set_node(pos, {name = "cicrev:campfire_lit"})
			itemstack:add_wear(65535 / 20)
			return itemstack
		end
	end,
})
