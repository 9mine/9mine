-- parses string in form of '<protocol>!<hostname>!<port_number> <initial_path>(optional)'
parse_remote_address = function(addr)
    local t = {}
    for s in string.gmatch(addr, "[^ ]+") do table.insert(t, s) end

    local addr = t[1]
    -- set initial path if not present
    local path = t[2] ~= nil and string.match(t[2], "^/.*$") or "/"

    local th = {}
    if not addr then return end
    for s in string.gmatch(addr, "[^!]+") do table.insert(th, s) end

    local prot = th[1]
    local host = th[2]
    local port = tonumber(th[3])
    local host_info = {prot = prot, host = host, port = port}
    return host_info, addr, path
end
