local path = minetest.get_modpath("grid")
dofile(path .. "/modload.lua")
grid_conf = Settings(path .. "/mod.conf")

require 'automount'
require 'home_platform'
automount = automount()
root_cmdchan = automount:connect_to_root()