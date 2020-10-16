-- include libraries
socket = require 'socket'

-- include files 
local path = minetest.get_modpath("youtube")

-- load mod.conf settings
youtube_conf = Settings(path .. "/mod.conf")

-- nodes

-- tools
dofile(path .. "/tools/connect_subs.lua")
dofile(path .. "/tools/connect_search.lua")
dofile(path .. "/tools/arrow.lua")

-- functions
dofile(path .. "/funcs/tx_exists.lua")
dofile(path .. "/funcs/populate_inventory.lua")
dofile(path .. "/funcs/save_thumb.lua")
dofile(path .. "/funcs/show_thumbs.lua")
dofile(path .. "/funcs/list_youtube.lua")
dofile(path .. "/funcs/spawn_youtube.lua")
dofile(path .. "/funcs/check_results.lua")
dofile(path .. "/funcs/blink.lua")
dofile(path .. "/funcs/spawn_subs.lua")
dofile(path .. "/funcs/update_subs.lua")
dofile(path .. "/funcs/generate_subs.lua")
dofile(path .. "/funcs/add_video_item.lua")
dofile(path .. "/funcs/send_warning.lua")

-- on player join
dofile(path .. "/on_join/inventory.lua")

-- events
dofile(path .. "/events/events.lua")
dofile(path .. "/events/process_urls.lua")
dofile(path .. "/events/grid.lua")
dofile(path .. "/events/search.lua")
dofile(path .. "/events/connect_subs.lua")
dofile(path .. "/events/connect_search.lua")

-- entities 
dofile(path .. "/entities/subs.lua")
dofile(path .. "/entities/search.lua")
dofile(path .. "/entities/result.lua")

-- 9p interactions
dofile(path .. "/nodes/video.lua")
