-- deletes map data on world startup

local worldpath = minetest.get_worldpath()
minetest.rmdir(worldpath .. "/map.sqlite", false)
