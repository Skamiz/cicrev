local modname = minetest.get_current_modname()

minetest.register_entity(modname .. ":name",{

	-- required minetest api props

	initial_properties = {
		physical = true,
		collide_with_objects = true,
		collisionbox = {...},
		visual = "mesh",
		mesh = "...",
		textures = {...},
	},


	-- required mobkit props

	timeout = [num],			-- entities are removed after this many seconds inactive
								-- 0 is never
								-- mobs having memory entries are not affected

	buoyancy = [num],			-- (0,1) - portion of collisionbox submerged
								-- = 1 - controlled buoyancy (fish, submarine)
								-- > 1 - drowns
								-- < 0 - MC like water trampolining

	lung_capacity = [num], 		-- seconds
	max_hp = [num],
	on_step = mobkit.stepfunc,
	on_activate = mobkit.actfunc,
	get_staticdata = mobkit.statfunc,
	logic = [function user defined],		-- older 'brainfunc' name works as well.

				-- optional mobkit props
				-- or used by built in behaviors
	physics = [function user defined] 		-- optional, overrides built in physics
	animation = {
		[name]={range={x=[num],y=[num]},speed=[num],loop=[bool]},		-- single

		[name]={														-- variant, animations are chosen randomly.
				{range={x=[num],y=[num]},speed=[num],loop=[bool]},
				{range={x=[num],y=[num]},speed=[num],loop=[bool]},
				...
			}
		...
		}
	sounds = {
		[name] = [string filename],				--single, simple,

		[name] = {								--single, more powerful. All fields but 'name' are optional
			name = [string filename],
			gain=[num or range],				--range is a table of the format {left_bound, right_bound}
			fade=[num or range],
			pitch=[num or range],
			},

		[name] = {								--variant, sound is chosen randomly
			{
			name = [string filename],
			gain=[num or range],
			fade=[num or range],
			pitch=[num or range],
			},
			{
			name = [string filename],
			gain=[num or range],
			fade=[num or range],
			pitch=[num or range],
			},
			...
		},
		...
	},
	max_speed = [num],					-- m/s
	jump_height = [num],				-- nodes/meters
	view_range = [num],					-- nodes/meters
	attack={range=[num],				-- range is distance between attacker's collision box center
		damage_groups={fleshy=[num]}},	-- and the tip of the murder weapon in nodes/meters
	armor_groups = {fleshy=[num]}
})
