require "socket"
require "class"

class("connection")

-- initialize connection object with basic connection information
function connection:connection(attach_string)
    local addr, prot, host, port = parse_attach_string(attach_string)
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
    local attachment = np.attach(tcp, "root", "")
    self.attachment = attachment
    minetest.chat_send_all("Attached to " .. self.addr)
    print("Attached to " .. self.addr)
    connections[self.addr] = self
end

function connection:reattach()
    self.tcp:close()
    print("Disconnected from " .. self.addr)
    self:attach()
end

function connection:is_alive()
    local conn = self.attachment
    local f = conn:newfid()
    local result = pcall(np.walk, conn, conn.rootfid, f, "../")
    if result then
        conn:clunk(f)
    end
    return result
end

-- parses string in form of '<protocol>!<hostname>!<port_number>'
parse_attach_string = function(attach_string)
    local info = {}
    for token in string.gmatch(attach_string, "[^!]+") do
        table.insert(info, token)
    end
    local prot = info[1]
    local host = info[2]
    local port = tonumber(info[3])
    return attach_string, prot, host, port
end
