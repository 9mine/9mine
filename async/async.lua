local  cqueues = require"cqueues"
local  socket = require"cqueues.socket"

local sct = socket.connect("localhost", 9000)
sct:settimeout(1)
local str = "world\n"
local byte_count, error_code = sct:send(str, 1, str:len())
print(byte_count, error_code)

local response, error_code = sct:recv("*l")
print(response, error_code)