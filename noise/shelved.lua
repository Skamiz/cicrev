local gradient_vectors =   {{x = 1, y = 0},
                            {x = -1, y = 0},
                            {x = 0, y = 1},
                            {x = 0, y = -1}}

-- Finnished, don't touch this annymore.
local function lerp(p1, p2, d)
    return (p1 * (1-d) + p2 * d)
end

function random_from_table(t)
    if #t < 1 then return {} end
    local reverse_table = {}
    for _, v in pairs(t) do
        table.insert(reverse_table, v)
    end
    return reverse_table[math.random(#reverse_table)]
end

local function perlin(x, y)
    local minx = math.floor(x)
    local miny = math.floor(y)

    local corners = {}

    corners[1] = {x = minx, y = miny}
    corners[2] = {x = minx + 1, y = miny}
    corners[3] = {x = minx + 1, y = miny + 1}
    corners[4] = {x = minx, y = miny + 1}


    for _, corner in ipairs(corners) do

        math.randomseed(corner.x*corner.y + noise_params.seed)
        corner.direction = random_from_table(gradient_vectors)
        corner.distance = {x = x - corner.x, y = y - corner.y}
        corner.influence = corner.direction.x * corner.distance.x + corner.direction.y * corner.distance.y
    end

    local result = lerp(lerp(corners[1].influence, corners[2].influence, x),
                        lerp(corners[4].influence, corners[3].influence, x),
                        y)
    return result
end

local function get_map_piece(minp, maxp)
    local map = {}
    for x = minp.x, maxp.x do
        map[x] = {}
        for y = minp.y, maxp.y do
            x_ = x / noise_params.spread.x
            y_ = y / noise_params.spread.y
            map[x][y] = (perlin(x_, y_)+1) / 5
        end
    end
    return map
end

noise_params = {
        offset = 0,
        scale = 1,
        spread = {x = 100, y = 100},
        seed = 80,
        octaves = 5,
        persist = 0.63,
        lacunarity = 2.0,
}

local minp, maxp = {x = 1, y = 1}, {x = 800, y = 600}

local map = get_map_piece(minp, maxp)

local g = love.graphics
g.setDefaultFilter("nearest", "nearest", 0)
local canvas = g.newCanvas()
g.setCanvas(canvas)

for x=1, #map do
  for y=1,#map[x] do
      g.setColor(map[x][y]-1, map[x][y]+1, map[x][y])
      -- g.setColor(map[x][y], map[x][y], map[x][y])
      g.points(x, y)
  end
end

g.setCanvas()
g.setColor(1, 1, 1)
function love.draw()
    g.draw(canvas, 0, 0, 0, 1)
end
