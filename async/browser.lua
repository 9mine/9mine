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
"tcp!postnix.pw!465",
"tcp!contrib.9front.org!564",
"tcp!kamalatta.ddnss.de!999",
"tcp!kamalatta.ddnss.de!9997"}
math.randomseed(os.time())
local first = np_over_tcp(arg[1] or list_server[math.random(#list_server)])
print("first is:" .. first.addr)
first:attach()

local start_first = socket.gettime()*1000
local directory = readdir(first.conn, arg[2] or "/")
for k, v in pairs(directory) do
    print(((arg[2] and arg[2] .. "/") or "/") .. v.name)
end
local end_first = socket.gettime()*1000
elapsed_time_first = end_first - start_first
print("first server " .. first.addr .. " readdir in: " .. string.format("%.2f", elapsed_time_first) .. "ms")