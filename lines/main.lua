local g = love.graphics

local start, stop = {0, 0}, {0, 0}
local canvas = g.newCanvas()
local max_straight = 2

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
        new_point[axis] = new_point[axis] + ((math.random()-0.5) * distance)
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

local function make_line(start, stop)
    local line  = {start, stop}
    local n = 2
    while line[n] do
        while get_too_long(line[n-1], line[n], max_straight) do
            table.insert(line, n, get_middle(line[n-1], line[n]))
        end
        n = n + 1
    end
    return line
end

local function make_line_sequential(line)
    local new_line = {}
    for _, v in ipairs(line) do
        table.insert(new_line, v[1])
        table.insert(new_line, v[2])
    end
    return new_line
end

local function draw_line_to_canvas(line)
    local canvas = g.newCanvas()
    g.setCanvas(canvas)
    -- g.line(line)
    -- g.setColor(1, 0, 0)
    g.points(line)
    g.setCanvas()
    return canvas
end

function love.load()
    g.setLineStyle("smooth")
end

function love.mousepressed(x, y)
    start = {x, y}
end

function love.mousereleased( x, y)
    stop = {x, y}
    local line = make_line(start, stop)
    line = make_line_sequential(line)
    canvas = draw_line_to_canvas(line)
end

function love.update()
    love.timer.sleep(0.1)
end

function love.draw()
    g.setColor(1, 1, 1)
    g.draw(canvas, 0, 0, 0, 1)
end
