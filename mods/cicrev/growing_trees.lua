local branch_nodebox = {
	type = "connected",
	fixed          = {-0.25, -0.25, -0.25, 0.25,  0.25, 0.25},
	connect_top    = {-0.25, -0.25, -0.25, 0.25,  0.5,  0.25}, -- y+
	connect_bottom = {-0.25, -0.5,  -0.25, 0.25,  0.25, 0.25}, -- y-
	connect_front  = {-0.25, -0.25, -0.5,  0.25,  0.25, 0.25}, -- z-
	connect_back   = {-0.25, -0.25,  0.25, 0.25,  0.25, 0.5 }, -- z+
	connect_left   = {-0.5,  -0.25, -0.25, 0.25,  0.25, 0.25}, -- x-
	connect_right  = {-0.25, -0.25, -0.25, 0.5,   0.25, 0.25}, -- x+
}
minetest.register_node("cicrev:branch", {
	description = "Branch",
	tiles = {"cicrev_log_oak.png"},
	groups = { snappy = 3, cracky = 1, choppy = 1, tree = 1 },
	paramtype = "light",
	drawtype = "nodebox",
	node_box = branch_nodebox,
	connects_to = {"group:tree", "group:log", "group:leaves"},
})
