stat_read = function(addr, path, player_name)
    local conn = connections[player_name][addr]
    local f = conn:newfid()
    np:walk(conn.rootfid, f, path)
    conn:open(f, 0)
    local st = conn:stat(f)
    conn:clunk(f)
    return st
end
