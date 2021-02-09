local async_socket  = require "async_socket"

--
local cnt = 0
function idle() cnt = cnt + 1 end
local cnn = async_socket.tcp_client(idle)
local ok = cnn:connect(nil, arg[1], arg[2])

print(ok and "Connection Successfully Made" or "Error connecting to " .. arg[1] .. ":" .. arg[2] )

cnn:close()