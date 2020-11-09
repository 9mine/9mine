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
require 'automount'
require 'events.events'
require 'events.connect'
require 'events.platform_properties'

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

-- chat
require 'chat.cmdchan'
require 'chat.graph'

platforms = platforms(graph)
common = common()
