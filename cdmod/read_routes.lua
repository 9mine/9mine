read_routes = function(host_info)
    local route = {}
    local tcp = socket:tcp()
    local connection, err = tcp:connect(host_info["host"], host_info["port"])
    if (err ~= nil) then error("Connection error: " .. dump(err)) end
    local conn = np.attach(tcp, "dievri", "")
    local f = conn:newfid()
    print("walking to new file" .. host_info["path"])
    np:walk(conn.rootfid, f, host_info["path"])
    conn:open(f, 0)
    local statistics = conn:stat(f)
    local READ_BUF_SIZ = 4096
    local offset = 0
    local content = nil
    local data = conn:read(f, offset, READ_BUF_SIZ)
    content = tostring(data)
    print("initial content ... " .. content)
    -- pprint(data)
    if data ~= nil then
        offset = offset + #data
    end
    for i = 1, 1, 2 do
        data = conn:read(f, offset, READ_BUF_SIZ)

        if (data == nil) then break end
        content = content .. tostring(data)
        offset = offset + #(tostring(data))
    end

    conn:clunk(f)
    tcp:close()
    local file = io.open("test.txt", "w")
    file:write(content)
    file:close()
    for line in io.lines("test.txt") do
        if string.match(line, "^[ ]*[%d]+") ~= nil and
            string.match(line, "%d+%.%d+%.%d+%.%d+") then
            table.insert(route, string.match(line, "%d+%.%d+%.%d+%.%d+"))
        end
    end
    return route
end
