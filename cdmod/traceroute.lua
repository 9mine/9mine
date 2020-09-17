traceroute = function(host_info, path)
    local tcp = socket:tcp()
    local connection, err = tcp:connect(host_info["host"], host_info["port"])
    if (err ~= nil) then
        error("Connection error: " .. dump(err))
    end
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
    for line in io.lines("test.txt") do print(" THIS IS LINE " .. line) end
end
