-- how to find minp of chunk
-- local minp = {x = 80 * math.floor((pos.x + 32) / 80) - 32,
-- 			y = 80 * math.floor((pos.y + 32) / 80) - 32,
-- 			z = 80 * math.floor((pos.z + 32) / 80) - 32}


local modname = minetest.get_current_modname()




function get_and_set_timer(pos, time, override)
    local timer = minetest.get_node_timer(pos)
    local will_start = override or not timer:is_started()
    if will_start then
        timer:start(time)
    end
    return will_start
end

function get_distance_squared(p1, p2)
    local distance_squared = 0
	local axis_distance
    for axis, _ in pairs(p1) do
        axis_distance = p1[axis] - p2[axis]
        distance_squared = distance_squared + (axis_distance * axis_distance)
    end
    return distance_squared
end

-- cheap hash for making randomseeds
local function string_to_number(str)
	local number = 0
	for i = 1, #str do
		number = number + str:byte(i) * 10 ^ i
	end
	return number
end

-- something I can hopefully use to make interesting caves

local function get_distance(p1, p2)
    local distance_squared = 0
    for axis, _ in pairs(p1) do
        axis_distance = p1[axis] - p2[axis]
        distance_squared = distance_squared + (axis_distance * axis_distance)
    end
    return math.sqrt(distance_squared)
end

local function get_middle(p1, p2)
    local new_point = {}
    local distance = get_distance(p1, p2)
    for axis, _ in pairs(p1) do
        new_point[axis] = (p1[axis] + p2[axis]) / 2
        new_point[axis] = new_point[axis] + ((math.random()-0.5) * distance * 0.5)
    end
    return new_point
end

local function get_too_long(p1, p2, max_straight)
    local distance_squared = 0
    for axis, _ in pairs(p1) do
        axis_distance = p1[axis] - p2[axis]
        distance_squared = distance_squared + (axis_distance * axis_distance)
    end
    if distance_squared > max_straight * max_straight then return true end
    return false
end

-- alingns all positions on the interger grid
local function floor_line(line)
    for _, point in ipairs(line) do
        for axis, value in pairs(point) do
            point[axis] = math.floor(value)
        end
    end
    return line
end

function make_line(start, stop)
	local rel_pos = {x = start.x % 80, y = start.y % 80, z = start.z % 80}
    math.randomseed(minetest.hash_node_position(rel_pos))
    local line  = {start, stop}
    local n = 2
    while line[n] do
        while get_too_long(line[n-1], line[n], 2) do
            table.insert(line, n, get_middle(line[n-1], line[n]))
        end
        n = n + 1
    end
    floor_line(line)
    return line
end
