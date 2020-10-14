stat_drop = function(a, path, name)
    local conn = connections[name][a]
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:open(f, 1)
    local st = conn:stat(f)
    st.length = 0
    conn:wstat(f, st)
end
