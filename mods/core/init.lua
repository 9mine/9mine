local path = minetest.get_modpath("core")
dofile(path .. "/modload.lua")

core_conf = Settings(path .. "/mod.conf")

-- global values
connections = {}
-- libraries 
require 'graph'
require "socket"
require "class"
require 'readdir'
require 'md5'
require 'connection'
require 'cmdchan'

np = require '9p'

-- mod files 
require 'events.events'
require 'events.connect'
require 'chat.commands.graph'

-- objects
require 'platform'
require 'stat'
require 'graphs.platforms'
require 'common'

-- node/entities
require 'entities.stat'
require 'nodes.platform'

-- tools
require 'tools.connect'
require 'tools.enter'

platforms = platforms(graph)
common = common()