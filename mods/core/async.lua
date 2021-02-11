local cqueues = require "cqueues"
local socket = require "cqueues.socket"
local sct1 = socket.connect("localhost", 9000)
sct1:settimeout(0)
local sct2 = socket.connect("localhost", 2701)
sct2:settimeout(0)

function socket_send(socket, message)
    socket:send(message, 1, message:len())
end

function socket_recv(socket)
    local response
    response = socket:recv("*l")
    return response
end

local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime;
    if timer >= 2 then
        local ready = {assert(cqueues.poll(sct1, sct2, 1))}
        if type(ready[1]) ~= "number" then
            for i = 1, #ready do
                if ready[i]:events() == "w" then
                    socket_send(ready[i], "world\n")
                else
                    local response = socket_recv(ready[i])
                    if response == nil then
                        socket_send(ready[i], "world\n")
					else
						minetest.chat_send_all("Response from sockets: " .. response)
					end
                end
            end
        end
        -- Read Response From servers each 2 seconds
        
        timer = 0
    end
end)
