config = luaconfig.loadConfig();
data = require 'data'
np = require '9p'
socket = require 'socket'
pprint = require 'pprint'
readdir = require 'readdir'
cache = {}
authenticated = false
local path = minetest.get_modpath("cdmod")
dofile(path .. "/auth_help.lua")
dofile(path .. "/auth_handler.lua")
dofile(path .. "/populate_inventory.lua")
dofile(path .. "/entity_directory.lua")
dofile(path .. "/entity_file.lua")
dofile(path .. "/node_platform.lua")
dofile(path .. "/tools.lua")
dofile(path .. "/events.lua")
dofile(path .. "/create_platform.lua")
dofile(path .. "/on_joinplayer.lua")
dofile(path .. "/read_directory.lua")
dofile(path .. "/connect.lua")
dofile(path .. "/graph_edge.lua")
dofile(path .. "/spawn_npc.lua")
mount_signer(config.newuser_addr)
