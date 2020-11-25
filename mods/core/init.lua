local path = minetest.get_modpath("core")
dofile(path .. "/modload.lua")

core_conf = Settings(path .. "/mod.conf")

-- global values
connections = {}
-- libraries 
require 'lfs'
require 'graph'
require "socket"
require "class"
require 'readdir'
md5 = require 'md5'
require 'connection'
require 'cmdchan'
require 'register'

filesize = require 'filesize'
np = require '9p'

-- tools
require 'tools.connect'
require 'tools.enter'
require 'tools.read'
require 'tools.write'
require 'tools.edit'
require 'tools.copy'
require 'tools.registry'
require 'tools.remove'
require 'tools.stat'

-- mod files 
require 'automount'
require 'events.ffi'
require 'events.core'
require 'events.stat'
require 'events.platform'

-- nodes
require 'nodes.dir'
require 'nodes.file'
require 'nodes.service'

-- crafts
require 'crafts.service'

-- objects
require 'platform'
require 'directory_entry'
require 'graphs.platforms'
require 'common'
require 'np_prot'
require 'texture'

-- node/entities
require 'entities.stat'
require 'nodes.platform'

-- chat
require 'chat.ffi'
require 'chat.cmdchan'
require 'chat.graph'
require 'chat.commands'
require 'chat.mvcp'

platforms = platforms(graph)
np_prot = np_prot()

current_hud = {}
functions = {}
filters = {}
crafts = {}
form_handlers = {}