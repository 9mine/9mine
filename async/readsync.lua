uint64 = require 'libs.uint64'
require 'socket'
require 'libs.class'
require 'mods.core.common'
pprint = require 'libs.pprint'
np = require 'libs.9p'
require 'libs.readdir'
require 'mods.core.9p_over_tcp'
local list_server = {"tcp!registry.demo.metacoma.io!30099",
"tcp!registry.demo.metacoma.io!30100",
"tcp!registry.9gridchan.org!6675",
"tcp!registry.9gridchan.org!7675",
"tcp!docs.a-b.xyz!909",
"tcp!oat.nine.sirjofri.de!564",
"tcp!ftrv.se!564",
"tcp!9p.io!564",
"tcp!postnix.pw!564",
"tcp!postnix.pw!564",
"tcp!postnix.pw!626",
"tcp!postnix.pw!626",
"tcp!postnix.pw!465",
"tcp!contrib.9front.org!564",
"tcp!kamalatta.ddnss.de!999",
"tcp!kamalatta.ddnss.de!9997"}
math.randomseed(os.time())
local first = np_over_tcp(arg[1] or list_server[math.random(#list_server)])
local second = np_over_tcp(arg[2] or list_server[math.random(#list_server)])
print("first is:") pprint(first)
first:attach()
print("second is:") pprint(second)
second:attach()
local start_first = socket.gettime()*1000
readdir(first.conn, "/")
local end_first = socket.gettime()*1000
elapsed_time_first = end_first - start_first
print("first server " .. first.addr .. " readdir in: " .. string.format("%.2f", elapsed_time_first) .. "ms")

local start_second = socket.gettime()*1000 
readdir(second.conn, "/")
local end_second = socket.gettime()*1000
elapsed_time_second = end_second - start_second
print("first server " .. second.addr .. " readdir in: " .. string.format("%.2f", elapsed_time_second) .. "ms")