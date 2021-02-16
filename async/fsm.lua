local machine = require('async/statemachine')
local socket = require "socket"
local serpent = require 'serpent'
local data = require 'data'

local tcp_socket = machine.create({
    initial = 'closed',
    events = {{
        name = 'connect',
        from = 'closed',
        to = 'established'
    }, {
        name = 'write',
        from = 'established',
        to = 'written'
    }, {
        name = 'read',
        from = 'written',
        to = 'established'
    }},
    callbacks = {
        onconnect = function(self, event, from, to, host, port)
            print("current state", self.state)
            print("connecting to ", host, port)
            local s = socket:tcp()
            local control, err = s:connect(host, port)
            if (err ~= nil and err ~= "timeout") then
                print("connect fail with error " .. err)
                os.exit(1)
            end
            self.socket = s
        end,
        onwrite = function(self, event, from, to, msg)
            local i, err = self.socket:send(msg)
            if (err == "timeout") then
                print("Send timeout")
            else
                print("Sended " .. i .. " bytes")
                sended = true
            end
        end,
        onread = function(self, event, from, to)
            local msg, err, partial = self.socket:receive("*l")
            if (err ~= nil and err ~= "timeout") then
                print("Receive error: " .. err)
                -- os.exit(1)
            end
            print(msg, partial)
        end
    }
})

tcp_socket:connect("gridfiles.dev.metacoma.io", 32444)
tcp_socket:write("test message\n")
tcp_socket:read()