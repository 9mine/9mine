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
require 'events.core'
require 'events.platform'

-- objects
require 'platform'
require 'stat'
require 'graphs.platforms'
require 'common'
require 'np_prot'

-- node/entities
require 'entities.stat'
require 'nodes.platform'

-- tools
require 'tools.connect'
require 'tools.enter'

-- chat
require 'chat.cmdchan'
require 'chat.graph'
require 'chat.commands'
require 'chat.mvcp'

platforms = platforms(graph)
common = common()
np_prot = np_prot()
