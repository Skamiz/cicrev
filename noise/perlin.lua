local sqrt2 = math.sqrt(2)
local gradient_vectors =   {{x = sqrt2, y = 0},
                            {x = -sqrt2, y = 0},
                            {x = 0, y = sqrt2},
                            {x = 0, y = -sqrt2}}

local vert_offsets =   {{x = 0, y = 0},
                        {x = 1, y = 0},
                        {x = 0, y = 1},
                        {x = 1, y = 1}}

-- Finnished, don't touch this annymore.
local function lerp(p1, p2, d)
    return (p1 * (1-d) + p2 * d)
end
-- also works as intended
local function dotProduct(v1, v2)
    return ((v1.x * v2.x) + (v1.y * v2.y))
end
-- as does this
local function vector_diff(a, b)
    local diff = {}
    diff.x = a.x - b.x
    diff.y = a.y - b.y
    return diff
end
-- need to find the proper 2d variant
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end

local function perlin(x, y, seed)
    local minX = math.floor(x)
    local minY = math.floor(y)
    -- local u, v = x%1, y%1
    local u, v = fade(x%1), fade(y%1)

    local corners = {{}, {}, {}, {}}

    for i = 1, 4 do
        corners[i].distance = vector_diff({x = u, y = v}, vert_offsets[i])
        math.randomseed((minX + vert_offsets[i].x) * 9000 + (minY + vert_offsets[i].y) * 777 + seed)
        corners[i].influence = dotProduct(gradient_vectors[math.random(4)], corners[i].distance)
    end

    local result = lerp(lerp(corners[1].influence, corners[2].influence, u),
                        lerp(corners[3].influence, corners[4].influence, u), v)

    return result
end

function get_value(x, y, noise_params)
    local value = 0
    for i = 1, noise_params.octaves do
        local lac = noise_params.lacunarity ^ (i - 1)
        local pers = noise_params.persist ^ (i - 1)
        value = value + (perlin(x_ * lac, y_ * lac, noise_params.seed) * pers)
    end
    value = noise_params.offset + (noise_params.scale * value)
    return value
end

function get_perlin_map(noise_params, chunk_size)
    local perlin_map = {}
    perlin_map.noise_params = noise_params
    perlin_map.chunk_size = chunk_size
    perlin_map.get_2d_map = function (self, minp)
        local map = {}
        for x = minp.x, minp.x + self.chunk_size.x do
            map[x] = {}
            for y = minp.y, minp.y + self.chunk_size.y do
                x_ = x / (self.noise_params.spread.x)
                y_ = y / (self.noise_params.spread.y)
                map[x][y] = get_value(x_, y_, self.noise_params)
            end
        end
        return map
    end
    return perlin_map
end
