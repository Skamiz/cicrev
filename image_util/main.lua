local function rgb_to_hash(r, g, b)
	r = math.floor(r*255)
	g = math.floor(g*255)
	b = math.floor(b*255)

	return r * 1000000 + g * 1000 + b
end

local function image_to_string(file)
	local imagedata = love.image.newImageData(file)
	local is = "local map = {\nsize = {x = " .. imagedata:getWidth() .. ", z = " .. imagedata:getHeight() .. "},\ndata = {\n"
	local colors = {}
	local i = 1
	for y = 0, imagedata:getHeight()-1 do
		for x = 0, imagedata:getWidth()-1 do
			local color = rgb_to_hash(imagedata:getPixel(x, y))

			if not colors[color] then
				colors[color] = i
				i = i + 1
			end

			is = is .. colors[color] .. ", "
		end
		is = is .. "\n"
	end
	is = is .. "}}\nreturn map"
	return is
end

function love.load()
	local dir = ""
	local files = love.filesystem.getDirectoryItems(dir)
	for k, file in ipairs(files) do
		if file:find(".png") then
			s = image_to_string(file)

			local success, message =love.filesystem.write( file:sub(1, -4) .. "lua", s)
			if success then
				print ('file created')
			else
				print ('file not created: '..message)
			end
		end
	end
	love.event.quit( exitstatus )
end
