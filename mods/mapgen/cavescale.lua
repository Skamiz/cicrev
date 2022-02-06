-- Credit to SmallJoker for the yappy source which I used as a template when writing this.
-- Credit to paramat for some ideas regarding cave generation using perlin noise.
-- This code is free. Do whatever you want with it.
-- If you make something cool, don't forget to share.

cavescale = {}

local SPREAD_XS = 32
local SPREAD_S = 96
local SPREAD_M = 256
local SPREAD_L = 512
local SQUASH = 0.7
local SPREAD_GEOLOGY = 512

cavescale.perlin_caves_1_XS = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_XS, y=SPREAD_XS*SQUASH, z=SPREAD_XS},
	octaves = 1,
	seed = -1000,
	persist = 0.5
}

cavescale.perlin_caves_1_S = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_S, y=SPREAD_S*SQUASH, z=SPREAD_S},
	octaves = 1,
	seed = -2000,
	persist = 0.5
}

cavescale.perlin_caves_1_M = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_M, y=SPREAD_M*SQUASH, z=SPREAD_M},
	octaves = 1,
	seed = -3000,
	persist = 0.5
}

cavescale.perlin_caves_1_L = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_L, y=SPREAD_L*SQUASH, z=SPREAD_L},
	octaves = 1,
	seed = -4000,
	persist = 0.5
}

cavescale.perlin_caves_2_XS = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_XS, y=SPREAD_XS*SQUASH, z=SPREAD_XS},
	octaves = 1,
	seed = -5000,
	persist = 0.5
}

cavescale.perlin_caves_2_S = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_S, y=SPREAD_S*SQUASH, z=SPREAD_S},
	octaves = 1,
	seed = -6000,
	persist = 0.5
}

cavescale.perlin_caves_2_M = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_M, y=SPREAD_M*SQUASH, z=SPREAD_M},
	octaves = 1,
	seed = -7000,
	persist = 0.5
}

cavescale.perlin_caves_2_L = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_L, y=SPREAD_L*SQUASH, z=SPREAD_L},
	octaves = 1,
	seed = -8000,
	persist = 0.5
}

cavescale.perlin_caves_3_XS = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_XS, y=SPREAD_XS*SQUASH, z=SPREAD_XS},
	octaves = 1,
	seed = -9000,
	persist = 0.5
}

cavescale.perlin_caves_3_S = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_S, y=SPREAD_S*SQUASH, z=SPREAD_S},
	octaves = 1,
	seed = -10000,
	persist = 0.5
}

cavescale.perlin_caves_3_M = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_M, y=SPREAD_M*SQUASH, z=SPREAD_M},
	octaves = 1,
	seed = -11000,
	persist = 0.5
}

cavescale.perlin_caves_3_L = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_L, y=SPREAD_L*SQUASH, z=SPREAD_L},
	octaves = 1,
	seed = -12000,
	persist = 0.5
}

cavescale.perlin_cavernosity = {
	offset = 0,
	scale = 1,
	spread = {x=SPREAD_GEOLOGY, y=SPREAD_GEOLOGY, z=SPREAD_GEOLOGY},
	octaves = 2,
	seed = -13000,
	persist = 0.5
}

minetest.register_on_mapgen_init(function(mgparams)
	if mgparams.mgname ~= "singlenode" then
		print("[cavescale_v2] Set mapgen to singlenode")
		minetest.set_mapgen_params({mgname="singlenode"})
	end
end)

minetest.register_on_generated(function(minp, maxp, seed)

	local air = minetest.get_content_id("air")
	local grass = minetest.get_content_id("default:dirt_with_grass")
	local dirt = minetest.get_content_id("default:dirt")
	local stone = minetest.get_content_id("default:stone")

	local t1 = os.clock()
	local sidelen = maxp.x - minp.x + 1
	local chulens = {x=sidelen, y=sidelen, z=sidelen}

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}
	local data = vm:get_data()
	local caves_1XS_map = minetest.get_perlin_map(cavescale.perlin_caves_1_XS, chulens):get3dMap_flat(minp)
	local caves_1S_map = minetest.get_perlin_map(cavescale.perlin_caves_1_S, chulens):get3dMap_flat(minp)
	local caves_1M_map = minetest.get_perlin_map(cavescale.perlin_caves_1_M, chulens):get3dMap_flat(minp)
	local caves_1L_map = minetest.get_perlin_map(cavescale.perlin_caves_1_L, chulens):get3dMap_flat(minp)
	local caves_2XS_map = minetest.get_perlin_map(cavescale.perlin_caves_2_XS, chulens):get3dMap_flat(minp)
	local caves_2S_map = minetest.get_perlin_map(cavescale.perlin_caves_2_S, chulens):get3dMap_flat(minp)
	local caves_2M_map = minetest.get_perlin_map(cavescale.perlin_caves_2_M, chulens):get3dMap_flat(minp)
	local caves_2L_map = minetest.get_perlin_map(cavescale.perlin_caves_2_L, chulens):get3dMap_flat(minp)
	local caves_3XS_map = minetest.get_perlin_map(cavescale.perlin_caves_3_XS, chulens):get3dMap_flat(minp)
	local caves_3S_map = minetest.get_perlin_map(cavescale.perlin_caves_3_S, chulens):get3dMap_flat(minp)
	local caves_3M_map = minetest.get_perlin_map(cavescale.perlin_caves_3_M, chulens):get3dMap_flat(minp)
	local caves_3L_map = minetest.get_perlin_map(cavescale.perlin_caves_3_L, chulens):get3dMap_flat(minp)
	local cavernosity_map = minetest.get_perlin_map(cavescale.perlin_cavernosity, chulens):get2dMap_flat({x=minp.x, y=minp.z})

	-- fill the floor in with grass/dirt/stone first
	nixyz = 1
	for z=minp.z,maxp.z,1 do
		for y=minp.y,maxp.y,1 do
			for x=minp.x,maxp.x,1 do
				if y <= -5 then
					data[area:index(x, y, z)] = stone
				elseif y <= -2 then
					data[area:index(x, y, z)] = dirt
				elseif y <= -1 then
					data[area:index(x, y, z)] = grass
				end
				nixyz = nixyz + 1
			end
		end
	end

	nixyz = 1
	nixz = 1
	for z=minp.z,maxp.z,1 do
		for y=minp.y,maxp.y,1 do
			for x=minp.x,maxp.x,1 do
				-- pull values from all the perlin noise maps
				local caves_1XS = caves_1XS_map[nixyz]
				local caves_1S = caves_1S_map[nixyz]
				local caves_1M = caves_1M_map[nixyz]
				local caves_1L = caves_1L_map[nixyz]
				local caves_2XS = caves_2XS_map[nixyz]
				local caves_2S = caves_2S_map[nixyz]
				local caves_2M = caves_2M_map[nixyz]
				local caves_2L = caves_2L_map[nixyz]
				local caves_3XS = caves_3XS_map[nixyz]
				local caves_3S = caves_3S_map[nixyz]
				local caves_3M = caves_3M_map[nixyz]
				local caves_3L = caves_3L_map[nixyz]
				local cavernosity = cavernosity_map[nixz]
				-- make our perlin noise scale with cavernosity near the surface
				-- low cavernosity means low density cave networks (poorly connected)
				-- high cavernosity means high density cave networks (well connected)
				local surface_influence = math.max(1-0.1*math.max((-y)/50,0),0)
				local spread = math.max(cavernosity,0)*SPREAD_XS + math.max(1-math.abs(cavernosity),0)*SPREAD_S + math.max(-cavernosity,0)*SPREAD_M
				local threshold = 0.03 * ((32/spread)*surface_influence + 1*(1-surface_influence))
				local caves_1_surface = math.max(cavernosity,0)*caves_1XS + math.max(1-math.abs(cavernosity),0)*caves_1S + math.max(-cavernosity,0)*caves_1M
				local caves_2_surface = math.max(cavernosity,0)*caves_2XS + math.max(1-math.abs(cavernosity),0)*caves_2S + math.max(-cavernosity,0)*caves_2M
				local caves_3_surface = math.max(cavernosity,0)*caves_3XS + math.max(1-math.abs(cavernosity),0)*caves_3S + math.max(-cavernosity,0)*caves_3M
				-- make our perlin noise scale up with depth
				-- small caves near the surface - big ones deep down
				local scale = math.min(0.1*math.max((-y)/100,0),1)
				local caves_1 = math.max(1-2*scale,0)*caves_1_surface + math.max(1-2*math.abs(scale-0.5),0)*caves_1M + math.max(1-2*(1-scale),0)*caves_1L
				local caves_2 = math.max(1-2*scale,0)*caves_2_surface + math.max(1-2*math.abs(scale-0.5),0)*caves_2M + math.max(1-2*(1-scale),0)*caves_2L
				local caves_3 = math.max(1-3*scale,0)*caves_3_surface + math.max(1-3*math.abs(scale-0.5),0)*caves_3M + math.max(1-3*(1-scale),0)*caves_3L
				local volume_1 = (math.abs(caves_1) < threshold)
				local volume_2 = (math.abs(caves_2) < threshold)
				local volume_3 = (math.abs(caves_3) < threshold)
				local radius = 3
				if ((volume_1 and volume_2) or (volume_2 and volume_3)) and y < 5 then
					-- clear out a sphere centred on this node
					for rz=math.max(z-radius,minp.z),math.min(z+radius,maxp.z),1 do
						for ry=math.max(y-radius,minp.y),math.min(y+radius,maxp.y),1 do
							for rx=math.max(x-radius,minp.x),math.min(x+radius,maxp.x),1 do
								if ((rx-x)^2+(ry-y)^2+(rz-z)^2) <= radius then
									data[area:index(rx, ry, rz)] = air
								end
							end
						end
					end
				end
				nixyz = nixyz + 1
				nixz = nixz + 1
			end
			nixz = nixz - sidelen
		end
		nixz = nixz + sidelen
	end

	local t2 = os.clock()
	minetest.log("action", minetest.pos_to_string(minp).." generated in "..math.ceil((t2 - t1) * 1000).." ms")

	vm:set_data(data)
	vm:set_lighting({day=16, night=0})
	vm:calc_lighting()
	--vm:update_liquids()
	vm:write_to_map(data)
end)
