local path = minetest.get_modpath("core")
-- custom modloader
dofile(path .. "/modload.lua")

-- global values
connections = {}

require 'readdir'
require 'md5'
require 'connection'

np = require '9p'
g = require 'graph'

dofile(path .. "/on_join/inventory.lua")
dofile(path .. "/tools/connect.lua")
dofile(path .. "/events/events.lua")
dofile(path .. "/events/connect.lua")
