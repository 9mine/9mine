local path = minetest.get_modpath("core")
dofile(path .. "/modload.lua")
core_conf = Settings(path .. "/mod.conf")

require 'automount'
require 'home_platform'
automount = automount()
root_cmdchan = automount:connect_to_root()