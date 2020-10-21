file_read = function(addr, path, player_name)
    local conn = connections[player_name][addr]
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:open(f, 0)
    local buf_size = 4096
    local offset = 0
    local response = ""
    while (true) do
        local dt = conn:read(f, offset, buf_size)
        if (dt == nil) then break end
        response = response .. tostring(dt)
        offset = offset + #dt
    end
    conn:clunk(f)
    return response
end
