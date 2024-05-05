
local test_def = {
	description = "shapes test node",
	tiles = {"shapes_test_node.png"},
	groups = {["not_in_survival_inventory"] = 1},
}
minetest.register_node("shapes:test_node", test_def)

for shape_name, register in pairs(shapes.register) do
	local test_def = table.copy(test_def)
	test_def.description = test_def.description .. " (" .. shape_name .. ")"
	register("shapes:test_node_" .. shape_name, test_def)
end
