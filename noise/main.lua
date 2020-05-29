local g = love.graphics
g.setDefaultFilter("nearest", "nearest", 0)
require("perlin")

local chunk_size = {x = 600, y = 600}
local noise_params = {
        offset = 100.0,
        scale = -20000.0,
        spread = {x = 200, y = 200},
        seed = 0,
        octaves = 1,
        persist = 0.5,
        lacunarity = 2,
}

local minp, maxp = {x = 1, y = 1}, {x = 100, y = 100}



local function draw_map_to_canvas(map)
    local canvas = g.newCanvas()
    g.setCanvas(canvas)
    for x=1, #map do
      for y=1,#map[x] do
          if map[x][y] < 0 then
              g.setColor(0, 0, 1-(1+map[x][y]))
          elseif map[x][y] > 0 then
              g.setColor(map[x][y], map[x][y], 0)
          else
              g.setColor(1, 0, 0)
          end
          g.points(x, y)
      end
    end
    g.setCanvas()
    return canvas
end

function love.load()
    canvas = draw_map_to_canvas(get_perlin_map(noise_params, chunk_size):get_2d_map(minp))
end

function love.mousepressed(x, y)
    noise_params.seed = noise_params.seed + 1
    canvas = draw_map_to_canvas(get_perlin_map(noise_params, chunk_size):get_2d_map(minp))
end

function love.mousereleased( x, y)

end

function love.update()
    love.timer.sleep(0.1)
end

function love.draw()
    g.setColor(1, 1, 1)
    g.draw(canvas, 0, 0, 0, 1)
end
