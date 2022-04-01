local c_dirt = minetest.get_content_id("cicrev:dirt_with_grass")
local c_stone = minetest.get_content_id("df_stones:schist")
local c_gair = minetest.get_content_id("lanterns:light_14")
-- TODO: override 'remove_node' to place glowing air instead
local c_air = minetest.CONTENT_AIR

minetest.set_mapgen_setting("water_level", "0", true)

local basal_top = 47
local basal_bottom = -32
local blend_dist = 10

--noise parameters
np_3d = {
    offset = 0,
    scale = 1,
    spread = {x = 32, y = 16, z = 32},
    seed = 0,
    octaves = 2,
    persist = 0.5,
    lacunarity = 2,
    -- flags = "eased",
}

np_2d = {
    offset = 0,
    scale = 10,
    spread = {x = 40, y = 40, z = 40},
    seed = 0,
    octaves = 1,
    persist = 1,
    lacunarity = 1.0,
	flags = "noeased",
}

local side_lenght = 80
local chunk_size = {x = 80, y = 80, z = 80}
local chunk_area = VoxelArea:new{MinEdge={x = 1, y = 1, z = 1}, MaxEdge=chunk_size}

local nobj_3d = noise_handler.get_noise_object(np_3d, chunk_size)
local nobj_2d = noise_handler.get_noise_object(np_2d, chunk_size)

local data = {}

minetest.register_on_generated(function(minp, maxp, blockseed)
    if maxp.y < basal_bottom or minp.y > basal_top then return end

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	local flat_area = VoxelArea:new({MinEdge=emin, MaxEdge={x = emax.x, y = emin.y, z = emax.z}})
	vm:get_data(data)

    local nvals_3d = nobj_3d:get_3d_map_flat(minp)
    local nvals_2d = nobj_2d:get_2d_map_flat(minp)



    math.randomseed(blockseed)

	local ni = 0
	for z = minp.z, maxp.z do
		for y = minp.y, maxp.y do
			for x = minp.x, maxp.x do
				local vi = area:index(x, y, z)

				local nv_3d = nvals_3d[(z - minp.z) * 80 * 80 + (y - minp.y) * 80 + (x - minp.x) + 1]
                local nv_2d = nvals_2d[(z-minp.z) * 80 + (x-minp.x) + 1]

				ni = ni + 1
				-- local nv_3d = nvals_3d[ni]


                if y == basal_bottom or y == basal_top then
                	data[vi] = c_stone
                end

				-- if nv_2d > y then
				-- 	data[vi] = c_dirt
				-- end
                --
                local dist = math.min(math.abs(y - basal_bottom), math.abs(y - basal_top))

				if nv_3d < 0 or (dist <= blend_dist and nv_3d < math.pow((blend_dist-dist)/blend_dist, 2)) then
				-- if nv_3d < math.max(0, math.pow((blend_dist-dist)/blend_dist, 2)) then
					data[vi] = c_stone
				end

				if data[vi] == c_air then
					data[vi] = c_gair
				end

			end
		end
	end

	vm:set_data(data)
    -- minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
end)

minetest.register_abm({
    label = "Air to glow",
    nodenames = {"air"},
    interval = 1,
    chance = 1,
    min_y = basal_bottom,
    max_y = basal_top,
    action = function(pos, node, active_object_count, active_object_count_wider)
        minetest.set_node(pos, {name = "lanterns:light_5"})
    end,
})
