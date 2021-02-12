local cqueues = require "cqueues"
local socket = require "cqueues.socket"
local pprint = require 'libs.pprint'
local serpent = require 'serpent'
local data = require 'data'

local metacoma = socket.connect {
    host = "gridfiles.dev.metacoma.io",
    port = 32333,
    nonblock = true

}
metacoma:settimeout(0)
local sent_over = false
--local prev_in_mode, prev_out_mode = metacoma:setmode("b", "b")
--print(prev_in_mode, prev_out_mode)
--local prev_in_buf, prev_out_buf = metacoma:setbufsiz(1024, 1024)
--print(prev_in_buf, prev_out_buf)
local full_resp = ""
local send_marker = 0
local total_bytes
local full_sent = false
while true do
    local polled = {assert(cqueues.poll(metacoma, 0))}
    for i = 1, #polled do 
        local sct = polled[i]
        if sct == 0 then 
        else
            print(serpent.block(sct:events()))
            if (sct:events() == "r" and sent_over) or sent_over then 
                local response, error = sct:recv("*l")
                print("Read error: ", error)
                print(response and "Response length: " .. string.len(response))
                if response ~= nil then 
                full_resp = full_resp .. response
                print("Accumulated response length: " .. string.len(full_resp))
                else
                    if full_resp ~= "" then 
                        print(full_resp)
                        sent_over = false
                        full_resp = ""
                    end
                end
            else
                local to_send = string.rep("worlds", 10000) .. "\n"
                print("Length of sent data: " .. string.len(to_send))
                local sent_bytes, error = sct:send(to_send, send_marker + 1, string.len(to_send))
                send_marker = send_marker + sent_bytes
                print(serpent.block(sent_bytes), serpent.block(error))
                print("total sent: " .. send_marker)
                if send_marker == string.len(to_send) then 
                    full_sent = true
                end
                if error == nil and full_sent then 
                send_marker = 0
                sent_over = true
                end
            end
                
            
        end
    end
    os.execute("sleep 1")
end



--[[if type(ready[1]) ~= "number" then
    for i = 1, #ready do
        if ready[i] == 0 then
            break
        end
        if ready[i]:events() == "w" or not sent_over then
            print("events before: ", serpent.block(ready[i]:events()))
            if ready[i]:events() == "r" then
                local to_send = string.rep("world", 3) .. "\n"
                print("Length of sent data: " .. string.len(to_send))
                local sent = ready[i]:xwrite(to_send)
                local sent_over = true

            elseif ready[i]:events() == "w" then
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
                    sent_over = false
                end
            end
        end
    end
end
--]]