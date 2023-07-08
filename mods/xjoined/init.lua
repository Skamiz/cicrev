local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

xjoined = {}
dofile(modpath.."/api.lua")
dofile(modpath.."/content.lua")
