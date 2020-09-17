traceroute = function(host_info, path)
    local tcp = socket:tcp()
    local connection, err = tcp:connect(host_info["host"], host_info["port"])
    if (err ~= nil) then error("Connection error: " .. dump(err)) end
    local conn = np.attach(tcp, "dievri", "")
    local f = conn:newfid()

    np:walk(conn.rootfid, f, path)
    conn:open(f, 0)
    local statistics = conn:stat(f)
    local buf = conn:read(f, 0, statistics.length - 1)
    local content = tostring(buf)

    conn:clunk(f)
    tcp:close()
    local file = io.open("test.txt", "w")
    file:write(content)
    file:close()
    local route = {}
    for line in io.lines("test.txt") do
        if string.match(line, "^[ ]*[%d]+") ~= nil and
            string.match(line, "%d+%.%d+%.%d+%.%d+") then
            table.insert(route, string.match(line, "%d+%.%d+%.%d+%.%d+"))
        end
    end
    for k, v in pairs(route) do
       local entity = minetest.add_entity({
            x = math.random(-15, 15),
            y = math.random(-15, 15),
            z = math.random(-15, 15)
        }, "cdmod:host")
        entity:set_nametag_attributes({color = "black", text = v})
        entity:set_armor_groups({immortal = 0})
        entity:get_luaentity().ip = v
    end

    for k, v in pairs(route) do
        
    end
end
