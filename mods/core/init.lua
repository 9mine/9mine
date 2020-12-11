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
require '9p_over_tcp'
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
require 'recipes'
require 'events.ffi'
require 'events.core'
require 'events.stat'
require 'events.platform'
require 'events.registry'
require 'crafts.ns'
require 'users'

-- nodes
require 'nodes.dir'
require 'nodes.file'
require 'nodes.service'
require 'nodes.platform'
require 'nodes.ns'

-- objects
require 'connections'
require 'platform'
require 'directory_entry'
require 'graphs.graphs'
require 'graphs.player_graph'
require 'common'
require 'np_prot'
require 'texture'
require 'mounts'
require 'buffer'

-- entities
require 'entities.stat'

-- chat
require 'chat.ffi'
require 'chat.cmdchan'
require 'chat.graph'
require 'chat.commands'
require 'chat.mvcp'
connections = connections()
graphs = graphs()
np_prot = np_prot()
mounts = mounts()

current_hud = {}
functions = {}
filters = {}
crafts = {}
form_handlers = {}

area_store = AreaStore()