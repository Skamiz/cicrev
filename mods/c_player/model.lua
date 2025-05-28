minetest.register_on_joinplayer(function(player, last_login)
	player:set_properties({
		visual = "mesh",
		-- mesh = "player_joints.b3d",
		mesh = "player_joints.glb",
		-- mesh = "character.b3d",
		textures = {"skin_template_joints.png"},
		visual_size = {x = 1, y = 1, z = 1},
	})
end)
