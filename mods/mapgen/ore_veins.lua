--[[
ore vein generation test

]]
local random

local registered_ores = {}
mapgen.registered_ores = registered_ores
local ore_id = 0
function mapgen.register_ore(ore_def)
	ore_id = ore_id + 1
	ore_def.id = ore_id
	ore_def.registering_mod = minetest.get_current_modname()
	table.insert(registered_ores, ore_def)
	return ore_id
end
function mapgen.unregister_ore(ore_id)
	for i, ore_def in ipairs(registered_ores) do
		if ore_def.id == ore_id then
			table.remove(registered_ores, ore_id)
			return true
		end
	end
	minetest.log("warning", "No ore  with id: '" .. ore_id .. "' was found.")
	return false
end


minetest.register_on_mods_loaded(function()
	for _, ore_def in pairs(registered_ores) do
		-- ensure sane defautls
		ore_def.wherein = ore_def.wherein or {"group:natural_stone"}
		ore_def.minp = ore_def.minp or -100
		ore_def.maxp = ore_def.maxp or 20
		ore_def.clust_num_ores = ore_def.clust_num_ores or 15
		ore_def.clust_scarcity = ore_def.clust_scarcity or 15*15*15

		-- prepare content ids
		local ore_cid = {}
		for _, ore in pairs(ore_def.ore) do
			table.insert(ore_cid, minetest.get_content_id(ore))
		end
		ore_def.ore_cid = ore_cid

		local wherein_cid = {}
		for _, stone in pairs(ore_def.wherein) do
			if not stone:find("^group:") then
				wherein_cid[minetest.get_content_id(stone)] = true
			else
				for name, def in pairs(minetest.registered_nodes) do
					local group = stone:match("group:(.+)$")
					if def.groups and def.groups[group] then
						wherein_cid[minetest.get_content_id(name)] = true
					end
				end
			end
		end
		ore_def.wherein_cid = wherein_cid

		-- normalize ore extend definition
		if type(ore_def.minp) == "number" then
			ore_def.minp = vector.new(-32000, ore_def.minp, -32000)
		end
		if type(ore_def.maxp) == "number" then
			ore_def.maxp = vector.new( 32000, ore_def.maxp,  32000)
		end
	end
end)

mapgen.register_ore({
	ore = {"cicrev:vein_native_copper"}, -- can be multiple nodes
	-- wherein = {"group:natural_stone"}, -- if this is nil, generates in "group:natural_stone"
	wherein = {"air"}, -- if this is nil, generates in "group:natural_stone"
	minp = 0, -- if it's a single number take it to mean the y value
	maxp = 20, -- can also be a vector
	clust_num_ores = 20, -- if this is a function, it is called with the given position as argument and returns a number
	clust_scarcity = 20 * 20 * 20,
	-- noise_threshold = 0, -- see lua_api
	-- noise_params = {}
})


local directions = {
	{x = 0, y = 1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
}

local hash = minetest.hash_node_position
local hash = minetest.pos_to_string
local function get_ore_positions(start_pos, size)
	local ore_positions = {}
	local neighbor_positions = {start_pos}
	local considered_positions = {[hash(start_pos)] = true}

	for i = 1, size do
		local next_index = math.random(1, #neighbor_positions)

		-- bias the positions index to be more likely to select more recently added positions
		-- resulting in more "stringy" ore veins, which are less clustered towards the middle
		-- local l = next_index / #neighbor_positions
		-- l = math.pow(l, 0.5) -- best exponent to use here depends a bit on cluster size, biger cluster -> smaler exponent
		-- l = l * #neighbor_positions
		-- next_index = math.max(1, math.ceil(l))

		local next_pos = table.remove(neighbor_positions, next_index)
		table.insert(ore_positions, next_pos)

		for _, offset in ipairs(directions) do
			local p_pos = next_pos + offset
			if not considered_positions[hash(p_pos)] then
				table.insert(neighbor_positions, p_pos)
				considered_positions[hash(p_pos)] = true
			end
		end
	end

	return ore_positions
end

-- change nodes as necessary
local c_ore = minetest.get_content_id("cicrev:vein_native_copper")

minetest.set_mapgen_setting("water_level", "0", true)
local world_seed = minetest.get_mapgen_setting("seed")
world_seed = world_seed % 5000 -- when the seed is too large it breaks things



-- automatically detect necessary chunk_size
-- though in some circumstances you will want to increase it afterwards
local blocks_per_chunk = tonumber(minetest.settings:get("chunksize")) or 5
local side_lenght = blocks_per_chunk * 16
local chunk_size = {x = side_lenght, y = side_lenght, z = side_lenght}

-- persistent data table for node data
local data = {}

local v_one = vector.new(1, 1, 1)
minetest.register_on_generated(function(minp, maxp, chunkseed)
	-- early exit if the mapgen doesn't operate in this hight range
	-- TODO: after mods are loaded find maximal extends of ore generation and use them as bounds here
	if maxp.y < -100 or minp.y > 100 then return end

	-- local t0 = minetest.get_us_time()

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
	vm:get_data(data)

	math.randomseed(chunkseed, 5)

	for _, ore_def in ipairs(registered_ores) do
		local maxb = maxp:combine(ore_def.maxp, math.min) -- bounds in which ores can spawn
		local minb = minp:combine(ore_def.minp, math.max)
		local size = (maxb - minb) + v_one
		if not (size.x < 1 or size.y < 1 or size.z < 1) then
			local volume = size.x * size.y * size.z
			local num_veins = math.ceil(volume/ore_def.clust_scarcity)
			for i = 1, num_veins do
				local start_pos = vector.new(math.random(minb.x, maxb.x), math.random(minb.y, maxb.y), math.random(minb.z, maxb.z))
				local positions = get_ore_positions(start_pos, ore_def.clust_num_ores)

				for _, pos in pairs(positions) do
					local index = area:indexp(pos)
					if ore_def.wherein_cid[data[index]] then
						data[index] = c_ore
					end
				end
			end
		end
	end

	-- finishing up
	vm:set_data(data)
	-- minetest.generate_decorations(vm)
	-- minetest.generate_ores(vm)
	-- vm:update_liquids()
	-- vm:set_lighting({day = 0, night = 0})
	-- vm:calc_lighting()
	vm:write_to_map()
	-- print((minetest.get_us_time() - t0) / 1000000)
end)
