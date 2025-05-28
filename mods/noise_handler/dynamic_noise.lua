local modname = minetest.get_current_modname()
local dynamic_noises = {}
local noise_by_index = {}
local original_np = {}
noise_handler.noises = dynamic_noises

local storage = minetest.get_mod_storage()

local function update_dynamic_noise(name, params, chunk_size)
	dynamic_noises[name] = noise_handler.get_noise_object(params, chunk_size)
	dynamic_noises[name].name = name

	storage:set_string(name, minetest.serialize(params))
	print("[dynamic_noise]: updating noise: " .. name)
end
noise_handler.register_dynamic_noise = function(name, params, chunk_size)
	dynamic_noises[name] = noise_handler.get_noise_object(params, chunk_size)
	dynamic_noises[name].name = name
	original_np[name] = params
	table.insert(noise_by_index, name)

	local changed = storage:get(name)
	if changed then
		print("[dynamic_noise]: loading noise params from previous sesion: " .. name)
		update_dynamic_noise(name, minetest.deserialize(changed), chunk_size)
	end
end



-- FORMSPEC
--[[
offset - numer
scale - number
spread - vector
seed - number
octaves - whole number
persistance - number
lacunarity - number - supposedly no less than 1
flags - defaults/eased/noeased/absvalue
]]
local function get_noise_settings(name)
	local np = dynamic_noises[name].params

end


local function get_noise_fs(name)
	local no = dynamic_noises[name]
	local np = no.params
	local ft = noise_handler.flags_to_table(np.flags)
	local fs = {
		"button[5.5,0;1.5,0.75;update;Update]",
		"button[5.5,1;1.5,0.75;reset;Reset]",
		-- TODO: button which deletes current chunk

		"container[0,0]",
		"field[0,0;1.5,0.5;offset;Offset;" .. np.offset .. "]",
		"field[1.75,0;1.5,0.5;scale;Scale;" .. np.scale .. "]",
		"field[3.5,0;1.5,0.5;seed;Seed;" .. np.seed .. "]",
		"container[0,0.5]",
		-- "label[0,0;Spread]",
		"field[0,0.5;1.5,0.5;spread_x;Spread X;" .. np.spread.x .. "]",
		"field[1.75,0.5;1.5,0.5;spread_y;Spread Y;" .. np.spread.y .. "]",
		"field[3.5,0.5;1.5,0.5;spread_z;Spread Z;" .. np.spread.z .. "]",
		"container_end[]",
		"field[0,2;1.5,0.5;octaves;Octaves;" .. np.octaves .. "]",
		"field[1.75,2;1.5,0.5;persist;Persistance;" .. np.persist .. "]",
		"field[3.5,2;1.5,0.5;lacunarity;Lacunarity;" .. np.lacunarity .. "]",

		"field_close_on_enter[offset;false]",
		"field_close_on_enter[scale;false]",
		"field_close_on_enter[seed;false]",
		"field_close_on_enter[spread_x;false]",
		"field_close_on_enter[spread_y;false]",
		"field_close_on_enter[spread_z;false]",
		"field_close_on_enter[octaves;false]",
		"field_close_on_enter[persist;false]",
		"field_close_on_enter[lacunarity;false]",
		"container_end[]",

		"container[0,3]",
		"label[0,0;Flags]",
		"checkbox[0,0.5;defaults;Defaults;" .. tostring(ft.defaults) .. "]",
		"checkbox[0,1;eased;Eased;" .. tostring(ft.eased) .. "]",
		"checkbox[2,0.5;absvalue;Absvalue;" .. tostring(ft.absvalue) .. "]",
		"checkbox[2,1;n0rmal;N0rmal;" .. tostring(ft.n0rmal) .. "]",
		"tooltip[n0rmal;Scales back amplitude added by aditional octaves.]",
		"container_end[]",

		"container[4,3]",
		"label[0,0;Info]",
		"label[0,0.5;Max: " .. no.max .."]",
		"label[0,1;Min: " .. no.min .."]",
		"container_end[]",
	}

	return table.concat(fs)
end
local function get_formspec(noise_name)
	local fs = {
		"formspec_version[6]",
		"size[12.75,9,false]",
		"textlist[0.5,0.5;4,8;noise_list;",
	}
	for i, name in pairs(noise_by_index) do
		fs[#fs + 1] = name
		fs[#fs + 1] = ","
	end
	fs[#fs] = "]"


	if noise_name then
		fs[#fs + 1] = "container[5,1]"
		fs[#fs + 1] = get_noise_fs(noise_name)
		fs[#fs + 1] = "container_end[]"
	end

	return table.concat(fs)
end
local function show_formspec(player, noise_name)
	-- minetest.close_formspec(player:get_player_name(), modname ..":noise_config")
	minetest.show_formspec(player:get_player_name(), modname ..":noise_config", get_formspec(noise_name))
end
minetest.register_chatcommand("noise_config", {
	-- params = "<name> <privilege>",
	description = "Show dynamic noise configuration formspec.",
	-- privs = {privs=true},

	func = function(name, param)
		-- local f = false
		-- for _, _ in pairs(dynamic_noises) do f = true break end
		-- if not f then
		-- 	minetest.chat_send_player(name, "There are no dynamic noises registered.")
		-- end
		local player = minetest.get_player_by_name(name)
		show_formspec(player)
	end,
})



local function print_table(t)
	for k, v in pairs(t) do
		minetest.chat_send_all(type(k) .. " : " .. tostring(k) .. " | " .. type(v) .. " : " .. tostring(v))
	end
end

local function copy_backup(t, b)
	local n = table.copy(t)
	for k, v in pairs(b) do
		if n[k] == nil then
			n[k] = v
		end
	end
end

local selected_noise_index
local n = 1
local all_flags = {
	"defaults",
	"eased",
	"absvalue",
	"n0rmal",
}
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= modname ..":noise_config" then return end
	if fields.noise_list == "INV" then return end -- sometimes minetest sends junk data
	minetest.chat_send_all("TAKE: " .. n .. " ---------------------")
	n = n + 1
	print_table(fields)
	print(dump(fields))
	if fields.noise_list then
		local event = minetest.explode_textlist_event(fields.noise_list)
		if event.type == "CHG" then
			show_formspec(player, noise_by_index[event.index])
			selected_noise_index = event.index
		end
		return true
	end

	if fields.reset then
		local cur_noise = dynamic_noises[noise_by_index[selected_noise_index]]
		update_dynamic_noise(cur_noise.name, original_np[cur_noise.name], cur_noise.chunk_size)
		show_formspec(player, noise_by_index[selected_noise_index])
		return true
	end

	if not selected_noise_index then return true end
	-- construct new noise parameters
	local cur_noise = dynamic_noises[noise_by_index[selected_noise_index]]
	local params = cur_noise.params
	-- local new_np = table.copy(params)
	local new_np = {
		offset = tonumber(fields.offset) or params.offset,
		scale = tonumber(fields.scale) or params.scale,
		spread = {
			x = tonumber(fields.spread_x) or params.spread.x,
			y = tonumber(fields.spread_y) or params.spread.y,
			z = tonumber(fields.spread_z) or params.spread.z,
		},
		seed = tonumber(fields.seed) or params.seed,
		octaves = tonumber(fields.octaves) or params.octaves,
		persist = tonumber(fields.persist) or params.persist,
		lacunarity = tonumber(fields.lacunarity) or params.lacunarity,
		flags = cur_noise.params.flags,
	}

	for _, flag in pairs(all_flags) do
		if fields[flag] ~= nil then
			local ft = noise_handler.flags_to_table(params.flags)
			ft[flag] = (fields[flag] == "true") and true or false
			new_np.flags = noise_handler.table_to_flags(ft)
		end
	end

	update_dynamic_noise(cur_noise.name, new_np, cur_noise.chunk_size)
	show_formspec(player, noise_by_index[selected_noise_index])
	return true

	-- if fields.update then
	-- 	local cur_noise = dynamic_noises[noise_by_index[selected_noise_index]]
	-- 	local params = cur_noise.params
	-- 	local new_np = {
	-- 		offset = tonumber(fields.offset) or params.offset,
	-- 	    scale = tonumber(fields.scale) or params.scale,
	-- 	    spread = {
	-- 			x = tonumber(fields.spread_x),
	-- 			y = tonumber(fields.spread_y),
	-- 			z = tonumber(fields.spread_z),
	-- 		},
	-- 	    seed = tonumber(fields.seed) or params.seed,
	-- 	    octaves = tonumber(fields.octaves) or params.octaves,
	-- 	    persist = tonumber(fields.persist) or params.persist,
	-- 	    lacunarity = tonumber(fields.lacunarity) or params.lacunarity,
	-- 		flags = cur_noise.params.flags,
	-- 	}
	-- 	update_dynamic_noise(cur_noise.name, new_np, cur_noise.chunk_size)
	-- 	show_formspec(player, noise_by_index[selected_noise_index])
	-- 	return true
	-- end
	-- for _, flag in pairs(all_flags) do
	-- 	if fields[flag] ~= nil then
	-- 		local cur_noise = dynamic_noises[noise_by_index[selected_noise_index]]
	-- 		local params = cur_noise.params
	-- 		local new_np = table.copy(params)
	-- 		local ft = noise_handler.flags_to_table(params.flags)
	-- 		ft[flag] = (fields[flag] == "true") and true or false
	-- 		new_np.flags = noise_handler.table_to_flags(ft)
	--
	-- 		dynamic_noises[cur_noise.name] = noise_handler.get_noise_object(new_np, cur_noise.chunk_size)
	-- 		dynamic_noises[cur_noise.name].name = cur_noise.name
	-- 		show_formspec(player, noise_by_index[selected_noise_index])
	-- 		return true
	-- 	end
	-- end
end)




-- HUD
--------------------------------------------------------------------------------
local huds = {}

local function add_noise_hud(player)
	local hud_info = {}
	huds[player] = hud_info
	hud_info.id = player:hud_add({
		type = "text",
		position = {x = 0, y = 0.5},
		alignment = {x = 1, y = 0},
		name = "dynamic noise display",
		text = "There are no registered dynamic noise objects.",
		z_index = 53,
		direction = 2,
	})
	hud_info.pos = player:get_pos()


	for name, nobj in pairs(dynamic_noises) do

	end
end
local function remove_noise_hud(player)
	player:hud_remove(huds[player].id)
	huds[player] = nil
end
local function get_hud_string(player)
	local hud_string = {}
	for name, nobj in pairs(dynamic_noises) do
		hud_string[#hud_string + 1] = name
		hud_string[#hud_string + 1] = ": "
		hud_string[#hud_string + 1] = string.format("%.3f", nobj:get_2d(player:get_pos():round()))
		hud_string[#hud_string + 1] = "\n"
	end
	return table.concat(hud_string)
end

minetest.register_on_joinplayer(
	function(player)
		add_noise_hud(player)
	end
)
minetest.register_on_leaveplayer(
	function(player, timed_out)
		remove_noise_hud(player)
	end
)
minetest.register_globalstep(function(dtime)
	for player, hud_info in pairs(huds) do
		local new_pos = player:get_pos()
		if new_pos:equals(hud_info.pos) then return end
		player:hud_change(hud_info.id, "text", get_hud_string(player))
	end
end)

-- for i, player in pairs(minetest.get_connected_players()) do	print(player:get_player_name()) end
