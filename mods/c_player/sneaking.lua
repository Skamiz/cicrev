--[[
TODO: maybe raycasts can be used at the corners of the full collision box
	to determine if it's possible to stand up?

can a raycast detect a collision when it starts and ends withing the same node?

But what I actually will do have the casts go from current top corners to
standing tall top corners. That should definitively cover more bases
maybe corenrs and middle too to avoid more edge cases

but but also check out: core.get_node_boxes(box_type, pos, [node])

]]

local sneaking = {
	eye_height = 1.25,
	collisionbox = {
		-0.3, 0, -0.3,
		0.3, 23/16, 0.3,
	},
}
local not_sneaking = {
	eye_height = c_player.default_properties.eye_height,
	collisionbox = c_player.default_properties.collisionbox,
}

local function start_sneaking(player)
	player:set_properties(sneaking)
end
local function stop_sneaking(player)
	player:set_properties(not_sneaking)
end

c_key_events.register_callback(start_sneaking, "sneak", "pressed")
c_key_events.register_callback(stop_sneaking, "sneak", "released")
