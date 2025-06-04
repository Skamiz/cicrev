if not fast_craft then return end
local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local name_prefix = modname .. ":"

local function item_name(name)
	return name_prefix .. name
end


fast_craft.register_condition("near_kiln", {
	func = function(player)
		local pos = player:get_pos()
		return core.find_node_near(pos, 3, "cicrev:kiln", true)
	end,
	-- not yet used
	description = "Player is near kiln.",
	-- icon = *.png file or item name representing this condition
})

-- ores to ingots
fast_craft.register_craft({
	output = {item_name("ingot_copper"), 1},
	input = {
		[item_name("ore_native_copper")] = 1,
	},
	conditions = {
		["near_kiln"] = true,
	}
})
fast_craft.register_craft({
	output = {item_name("ingot_iron"), 1},
	input = {
		[item_name("ore_hematite")] = 1,
	},
	conditions = {
		["near_kiln"] = true,
	}
})
fast_craft.register_craft({
	output = {item_name("ingot_steel"), 3},
	input = {
		[item_name("ore_hematite")] = 3,
		[item_name("ore_native_platinum")] = 1,
	},
	conditions = {
		["near_kiln"] = true,
	}
})
fast_craft.register_craft({
	output = {item_name("ingot_platinum"), 1},
	input = {
		[item_name("ore_native_platinum")] = 2,
	},
	conditions = {
		["near_kiln"] = true,
	}
})

-- ingot to blocks
fast_craft.register_craft({
	output = {item_name("block_copper"), 1},
	input = {[item_name("ingot_copper")] = 8,},
})
fast_craft.register_craft({
	output = {item_name("block_iron"), 1},
	input = {[item_name("ingot_iron")] = 8,},
})
fast_craft.register_craft({
	output = {item_name("block_steel"), 1},
	input = {[item_name("ingot_steel")] = 8,},
})
fast_craft.register_craft({
	output = {item_name("block_platinum"), 1},
	input = {[item_name("ingot_platinum")] = 8,},
})

-- blocks to ingost
fast_craft.register_craft({
	output = {item_name("ingot_copper"), 8},
	input = {[item_name("block_copper")] = 1,},
})
fast_craft.register_craft({
	output = {item_name("ingot_iron"), 8},
	input = {[item_name("block_iron")] = 1,},
})
fast_craft.register_craft({
	output = {item_name("ingot_steel"), 8},
	input = {[item_name("block_steel")] = 1,},
})
fast_craft.register_craft({
	output = {item_name("ingot_platinum"), 8},
	input = {[item_name("block_platinum")] = 1,},
})
