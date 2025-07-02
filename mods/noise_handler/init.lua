local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

noise_handler = {}

dofile(modpath.."/util.lua")
dofile(modpath.."/noise_object.lua")
-- dofile(modpath.."/dynamic_noise.lua")
