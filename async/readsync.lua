uint64 = require 'libs.uint64'
require 'socket'
require 'libs.class'
require 'mods.core.common'
pprint = require 'libs.pprint'
np = require 'libs.9p'
require 'libs.readdir'
require 'mods.core.9p_over_tcp'

local npio = np_over_tcp("tcp!9p.io!564")
local ftrv = np_over_tcp("tcp!ftrv.se!564")
npio:attach()
ftrv:attach()
pprint(readdir(npio.conn, "/"))
pprint(readdir(ftrv.conn, "/"))

