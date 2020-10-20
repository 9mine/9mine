-- read output from the command previously executed 
-- by the cmd_write function
cmd_read = function(addr, player_name, lcmd)
    local conn = connections[player_name][addr]
    local f = conn:newfid()
    np:walk(conn.rootfid, f, lcmd)
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
