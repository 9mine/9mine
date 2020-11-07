require "socket"
require "class"

class("connection")

function connection:connection(connection_string)
    local addr, prot, host, port = parse_connection_string(connection_string)
    self.addr = addr
    self.prot = prot
    self.host = host
    self.port = port
end

function connection:attach()
    local tcp = socket:tcp()
    self.tcp = tcp
    local _, err = tcp:connect(self.host, self.port, "*", 0)

    if (err ~= nil) then
        print("Connection error to " .. self.addr .. ": " .. err)
        minetest.chat_send_all("Connection error to " .. self.addr .. ": " .. err)
        return
    end
    conn = np.attach(tcp, "root", "")
    minetest.chat_send_all("Connected to " .. self.addr)
    print("Connected to " .. self.addr)
    connections[self.addr] = conn
end

function connection:reattach() 
    self.tcp:close()
    print("Disconnected from " .. self.addr)
    self:attach()
end 

-- parses string in form of '<protocol>!<hostname>!<port_number> <initial_path>(optional)'
parse_connection_string = function(connection_string)
    local t = {}
    for s in string.gmatch(connection_string, "[^ ]+") do
        table.insert(t, s)
    end
    local addr = t[1]
    local th = {}
    if not addr then
        return
    end
    for s in string.gmatch(addr, "[^!]+") do
        table.insert(th, s)
    end
    local prot = th[1]
    local host = th[2]
    local port = tonumber(th[3])
    return addr, prot, host, port
end
