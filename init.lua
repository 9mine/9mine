-- include libraries
socket = require 'socket'

-- include files 
local path = minetest.get_modpath("youtube")

-- load mod.conf settings
youtube_conf = Settings(path .. "/mod.conf")

-- entities

plt = {}
-- manage platforms
dofile(path .. "/platforms/get_size.lua")
dofile(path .. "/platforms/node.lua")
dofile(path .. "/platforms/create.lua")
dofile(path .. "/platforms/update.lua")

-- tools
dofile(path .. "/tools/youtube.lua")

-- functions
dofile(path .. "/funcs/populate_inventory.lua")
dofile(path .. "/funcs/save_thumbnail.lua")
dofile(path .. "/funcs/show_thumbnails.lua")
dofile(path .. "/funcs/spawn_video.lua")
dofile(path .. "/funcs/blink.lua")

-- on player join
dofile(path .. "/on_join/inventory.lua")

-- events
dofile(path .. "/events/init.lua")
dofile(path .. "/events/video_id.lua")
dofile(path .. "/events/youtube.lua")

-- nodes 
dofile(path .. "/nodes/video.lua")

-- chat commands
-- chat messages
-- 9p interactions
