local path = minetest.get_modpath("core")
-- custom modloader
dofile(path .. "/modload.lua")

--global values
connections = {}

require 'socket'
require 'readdir'
require 'md5'
require 'connection'

np = require '9p'
g = require 'graph'


local conn = connection("tcp!localhost!1917 /tmp")
conn:attach()
conn:reattach()