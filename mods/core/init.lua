-- include libraries
socket = require 'socket'
np = require '9p'
g = require 'graph'
readdir = require 'readdir'
md5 = require 'md5'

-- set global variables 
-- holds attached 9p connections to different hosts
connections = {}
-- holds graphs data for different players
graph = g.open("mt-root")
graph:node("mt-root")
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

-- nodes
dofile(path .. "/nodes/file.lua")
dofile(path .. "/nodes/dir.lua")


-- manage platforms
dofile(path .. "/platforms/get_size.lua")
dofile(path .. "/platforms/node.lua")
dofile(path .. "/platforms/create.lua")
dofile(path .. "/platforms/update.lua")
dofile(path .. "/platforms/settings.lua")
dofile(path .. "/platforms/refresh.lua")
dofile(path .. "/platforms/resize.lua")

-- tools
dofile(path .. "/tools/attach.lua")
dofile(path .. "/tools/enter.lua")
dofile(path .. "/tools/console.lua")
dofile(path .. "/tools/read.lua")
dofile(path .. "/tools/edit.lua")
dofile(path .. "/tools/write.lua")
dofile(path .. "/tools/copy.lua")

-- forms
dofile(path .. "/forms/send_warning.lua")
dofile(path .. "/forms/show_output.lua")

-- functions
dofile(path .. "/funcs/parse_remote_address.lua")
dofile(path .. "/funcs/to_plt.lua")
dofile(path .. "/funcs/plt_by_name.lua")
dofile(path .. "/funcs/connect.lua")
dofile(path .. "/funcs/automount.lua")

--- cmd
dofile(path .. "/funcs/cmd/cmd_write.lua")
dofile(path .. "/funcs/cmd/cmd_read.lua")

--- common
dofile(path .. "/funcs/common/hex.lua")
dofile(path .. "/funcs/common/name_as_key.lua")
dofile(path .. "/funcs/common/get_table_length.lua")
dofile(path .. "/funcs/common/populate_inventory.lua")
dofile(path .. "/funcs/common/set_look.lua")

--- entities
dofile(path .. "/funcs/entities/get_entity.lua")
dofile(path .. "/funcs/entities/list_directory.lua")
dofile(path .. "/funcs/entities/list_path.lua")
dofile(path .. "/funcs/entities/remove_file.lua")
dofile(path .. "/funcs/entities/spawn_file.lua")

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
dofile(path .. "/funcs/mvcp/on_drop.lua")

-- on player join
dofile(path .. "/on_join/inventory.lua")
dofile(path .. "/on_join/init_conn.lua")

-- events
dofile(path .. "/events/events.lua")
dofile(path .. "/events/console.lua")
dofile(path .. "/events/spawn_attach.lua")
dofile(path .. "/events/spawn_console.lua")
dofile(path .. "/events/platform_settings.lua")
dofile(path .. "/events/edit.lua")

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
