file_write = function(addr, file_path, player_name, content)
    local conn = connections[player_name][addr]
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, file_path)
    conn:open(f, 1)
    local buf = data.new(content)
    conn:write(f, 0, buf)
    conn:clunk(f)
    conn:walk(conn.rootfid, f, file_path)
    conn:open(f, 1)
    local st = conn:stat(f)
    st.length = #buf
    conn:wstat(f, st)
    conn:clunk(f)

end
