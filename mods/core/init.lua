-- include libraries
socket = require 'socket'
np = require '9p'
graph = require 'graph'
readdir = require 'readdir'
md5 = require 'md5'

-- set global variables 
-- holds attached 9p connections to different hosts
connections = {}
-- holds graphs data for different players
graphs = {}

-- used to bind platform functions
plt = {}
-- include files 
local path = minetest.get_modpath("core")

-- load mod.conf settings
core_conf = Settings(path .. "/mod.conf")

-- entities
dofile(path .. "/entities/dir.lua")
dofile(path .. "/entities/file.lua")
dofile(path .. "/entities/console.lua")

-- manage platforms
dofile(path .. "/platforms/get_size.lua")
dofile(path .. "/platforms/node.lua")
dofile(path .. "/platforms/create.lua")
dofile(path .. "/platforms/update.lua")

-- tools
dofile(path .. "/tools/attach.lua")
dofile(path .. "/tools/enter.lua")
dofile(path .. "/tools/write.lua")
dofile(path .. "/tools/console.lua")

-- forms
dofile(path .. "/funcs/send_warning.lua")

-- functions
dofile(path .. "/funcs/parse_remote_address.lua")
dofile(path .. "/funcs/to_plt.lua")
dofile(path .. "/funcs/goto_plt.lua")
dofile(path .. "/funcs/plt_by_name.lua")
dofile(path .. "/funcs/connect.lua")

--- cmd
dofile(path .. "/funcs/cmd/cmd_write.lua")
dofile(path .. "/funcs/cmd/cmd_read.lua")

--- common 
dofile(path .. "/funcs/hex.lua")
dofile(path .. "/funcs/name_as_key.lua")
dofile(path .. "/funcs/get_table_length.lua")
dofile(path .. "/funcs/populate_inventory.lua")
dofile(path .. "/funcs/set_look.lua")

--- entities
dofile(path .. "/funcs/get_entity.lua")
dofile(path .. "/funcs/list_directory.lua")
dofile(path .. "/funcs/list_path.lua")
dofile(path .. "/funcs/remove_file.lua")
dofile(path .. "/funcs/spawn_file.lua")

-- helpfunc for mv/cp chat commands
dofile(path .. "/funcs/mvcp/get_parent_path.lua")
dofile(path .. "/funcs/mvcp/get_diff.lua")
dofile(path .. "/funcs/mvcp/flight_correction.lua")
dofile(path .. "/funcs/mvcp/flight.lua")
dofile(path .. "/funcs/mvcp/copy_entity.lua")
dofile(path .. "/funcs/mvcp/parse_mvcp_params.lua")
dofile(path .. "/funcs/mvcp/get_sources.lua")
dofile(path .. "/funcs/mvcp/get_destination.lua")
dofile(path .. "/funcs/mvcp/get_changes.lua")
dofile(path .. "/funcs/mvcp/map_changes_to_sources.lua")
dofile(path .. "/funcs/mvcp/graph_changes.lua")

-- on player join
dofile(path .. "/on_join/inventory.lua")
dofile(path .. "/on_join/init_graph.lua")
dofile(path .. "/on_join/init_conn.lua")

-- events
dofile(path .. "/events/events.lua")
dofile(path .. "/events/spawn_attach.lua")
dofile(path .. "/events/console.lua")

-- chat commands
dofile(path .. "/chat/commands/cd.lua")
dofile(path .. "/chat/commands/cp.lua")
dofile(path .. "/chat/commands/mv.lua")
dofile(path .. "/chat/commands/graph.lua")

-- chat messages
dofile(path .. "/chat/messages/cmdchan.lua")

-- 9p interactions
dofile(path .. "/9p/stat_read.lua")
dofile(path .. "/9p/file_write.lua")
dofile(path .. "/9p/file_read.lua")
dofile(path .. "/9p/file_create.lua")