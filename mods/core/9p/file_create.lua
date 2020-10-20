file_create = function(addr, path, player_name, file_name)
    local conn = connections[player_name][addr]
    local f, g = conn:newfid(), conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:clone(f, g)
    conn:create(g, file_name, 420, 1)
    conn:clunk(f)
    conn:clunk(g)
end

