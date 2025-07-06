local cartography = cartography

--[[
data_map = {
	name = "foo",
	width = 10,
	height = 10,
	data = {},
	generate_data = function(data_maps) end,
	depends = {"height", "normal"},
}
]]
cartography.registered_data_maps = {}
cartography.register_data_map = function(name, def)
	def.name = name
	def.area = VoxelArea(vector.new(1, 1, 1), vector.new(def.width, 1, def.height))
	cartography.registered_data_maps[name] = def
end

-- add info about minimal, maximal, and avarage data values to data_map
local function append_mma(data_map)
	local min, max, avarage = cartography.util.get_mma(data_map.data)
	data_map.min = min
	data_map.max = max
	data_map.avarage = avarage
end

-- generate data of all data maps, accounting for data map dependencies
cartography.generate_data_maps = function()
	local t0 = core.get_us_time()

	local maps_to_generate = {}
	for name, def in pairs(cartography.registered_data_maps) do
		maps_to_generate[name] = def
	end

	local loaded_something = true
	while loaded_something do
		loaded_something = false

		for name, data_map in pairs(maps_to_generate) do
			if cartography.util.depends_fulfilled(data_map.depends, cartography.registered_data_maps) then
				data_map.data = data_map:generate_data(cartography.registered_data_maps)

				if type(data_map.data[1]) == "number" then
					append_mma(data_map)
				end

				loaded_something = true
				maps_to_generate[name] = nil
				break -- restart loop because we just edited the table we are looping through
			end
		end
	end

	core.chat_send_all("[" .. cartography.modname .. "] generated data maps in " .. (minetest.get_us_time() - t0) / 1000000 .. " seconds")


	if next(maps_to_generate) then
		core.log("wanring", "Couldn't generate all data maps:" .. dump(maps_to_generate))
	end
end

-- save data_map data to mod storage
local function save_data_map(data_map)
	local name = data_map.name
	local data_string = core.serialize(data_map.data)
	cartography.mod_storage:set_string(name, data_string)
end

-- try loading data_map data from mod storage
local function load_data_map(data_map)
	local name = data_map.name
	local data_string = cartography.mod_storage:get(name)
	-- WARNING: this might potentially fail
	local data = core.deserialize(data_string or "")
	-- assert(data, "Failes to resolve string'" .. data_string .. "' into a data table.")
	if data then
		data_map.data = data

		if type(data_map.data[1]) == "number" then
			append_mma(data_map)
		end

		return true
	else
		return false
	end
end

-- save all data maps
local function save_data_maps()
	for name, data_map in pairs(cartography.registered_data_maps) do
		save_data_map(data_map)
	end
end

-- load all data maps
local function load_data_maps()
	for name, data_map in pairs(cartography.registered_data_maps) do
		load_data_map(data_map)
	end
end

core.register_on_mods_loaded(load_data_maps)
core.register_on_shutdown(save_data_maps)
