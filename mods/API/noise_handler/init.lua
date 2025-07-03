local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)

noise_handler = {}

dofile(modpath.."/util.lua")
dofile(modpath.."/noise_object.lua")
-- dofile(modpath.."/dynamic_noise.lua")
