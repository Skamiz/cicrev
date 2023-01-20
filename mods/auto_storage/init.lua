-- TODO: change the slot conf tab to use newest formspec version

local slot_conf = {}

local function save_locked(player)
    local meta = player:get_meta()
    meta:set_string("lock_conf", minetest.serialize(slot_conf[player:get_player_name()]))
end

minetest.register_on_joinplayer(
    function(player)
        local name = player:get_player_name()
        local inv = player:get_inventory()
        local size = inv:get_size("main")

        local meta = player:get_meta()

        local locked = minetest.deserialize(meta:get("lock_conf")) or {}
        for i = 1, size do
            if locked[i] == nil then
                locked[i] = i <= 8
            end
        end

        slot_conf[name] = locked
    end
)

local orig_get = sfinv.pages["sfinv:crafting"].get
sfinv.override_page("sfinv:crafting", {
    get = function(self, player, context)
        local fs = orig_get(self, player, context)
		return fs .. "style_type[image_button;bgimg=slot_conf_button.png]"
        .. "image_button[9,4;1,1;store_to_nearby.png;store_to_nearby;]"
		.. "tooltip[store_to_nearby;Store to nearby]"
		-- .. "listcolors[#00000069;#5A5A5A;#141318;#30434C;#FFF]" -- same as creative tabs
    end
})

if minetest.get_modpath("sfinv") then
	sfinv.register_page("auto_storage:config", {
	    title = "Slot Conf",
	    get = function(self, player, context)

			local locked = slot_conf[player:get_player_name()]
			local f = ""
			.. "formspec_version[4]"
			.. "size[10.25,10.25]"
			.. "bgcolor[;neither;]"
			.. "background[0,0;10.25,10.25;slot_conf_background.png]"
		    -- .. "label[0,4;Here you can configure which slots can be auto-stored.]"
			.. "listcolors[#777777;#929292;#00000000]"
			.. "list[current_player;main;0.25,5.25;8,4;]"
			.. "style_type[image_button;bgimg=slot_conf_button.png]"

			for i = 1, 32 do
			    local image = locked[i] and "locked.png" or "unlocked.png"
				local x = (i-1)%8
				local x_pos = x + ((x + 1) * 0.25)
				local y = math.floor((i-1)/8)
				local y_pos = y + ((y + 1) * 0.25)
			    f = f .. "image_button[" .. x_pos .. "," .. y_pos .. ";1,1;" .. image .. ";slot_" .. i .. ";]"
				if locked[i] then
					f = f .. "image[" .. x_pos .. "," .. y_pos + 5 .. ";1,1;locked_slot.png]"
				end
			end

			return f .. sfinv.get_nav_fs(player, context, context.nav_titles, context.nav_idx)
	    end
	})
end

local function store_to_nearby(player, range)
    local name = player:get_player_name()
    local p_inv = player:get_inventory()
    local locked = slot_conf[name]

    local p_pos = player:get_pos():round()
    p_pos.y = p_pos.y + 1

    local storage = minetest.find_nodes_in_area(p_pos:subtract(range), p_pos:add(range), {"group:storage"}, false)
    for _, s_pos in pairs(storage) do
		if not minetest.is_protected(s_pos, name) then
	        local s_inv = minetest.get_inventory({type = "node", pos = s_pos})

	        for i, lock in ipairs(locked) do
	            if not lock then
	                local stack = p_inv:get_stack("main", i)
	                if not stack:is_empty() then
	                    if s_inv:contains_item("main", stack:get_name(), false) then
	                        local leftover = s_inv:add_item("main", stack)
	                        p_inv:set_stack("main", i, leftover)
	                    end
	                end
	            end
	        end
		end
    end
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    local locked = slot_conf[name]
    if fields["store_to_nearby"] then
        store_to_nearby(player, 2)
        return true
    end
    for i = 1, 32 do
        if fields["slot_" .. i] then
            locked[i] = not locked[i]
            save_locked(player)
            sfinv.set_page(player, "auto_storage:config")
            return true
        end
    end
end)
