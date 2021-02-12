local cqueues = require "cqueues"
local socket = require "cqueues.socket"
local pprint = require 'libs.pprint'
local serpent = require 'serpent'
local data = require 'data'

local sct2 = socket.connect {
    host = "localhost",
    port = 9000,
    nonblock = true

}
sct2:settimeout(0)

local prev_in_mode, prev_out_mode = sct2:setmode("b", "b")
print(prev_in_mode, prev_out_mode)
local prev_in_buf, prev_out_buf = sct2:setbufsiz(1024, 1024)
print(prev_in_buf, prev_out_buf)
local full_resp = ""
while true do 
    local ready = {assert(cqueues.poll(sct2, 0))}
    if type(ready[1]) ~= "number" then
    for i = 1, #ready do
        if ready[i] == 0 then break end
		print("events before: ", serpent.block(ready[i]:events()))
        if ready[i]:events() == "w" or ready[i]:events() == "r" then
            local to_send = string.rep("world", 10000) .. "\n"
            print("Length of sent data: " .. string.len(to_send))
            local sent = ready[i]:xwrite(to_send)
        elseif ready[i]:events() ~= "w" then
            local response, error = ready[i]:recv("*l")
            print("Receive error code is: " .. tostring(error))
            if response ~= nil then 
                full_resp = full_resp .. response 
            end
            print("Full length: " .. string.len(full_resp))
            print("events after: ", serpent.block(ready[i]:events()))
            if ready[i]:events() == "r" then
               -- minetest.chat_send_all(full_resp)
                full_resp = ""
            end
        end
    end
end
os.execute("sleep 1")
end