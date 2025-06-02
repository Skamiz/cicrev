local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
-- dofile(modpath .. "/foo.lua")
--[[
do something when a player starts sleeping
do something when the player stops sleeping
do something when the count of sleeping players changes
limit whether a player can sleep
start player sleep
end player sleep
get list of all sleeping players

is player sleeping?
end all players sleep
percentage/ratio of players sleeping?

default for skip night
default for accelerate time
default sleep state for c_player
default disable interact while sleep
default switch to third person while sleep
]]


c_sleep = {}

dofile(modpath .. "/api.lua")
dofile(modpath .. "/integration.lua")
