class 'np_prot'

function np_prot.stat_read(conn, path)
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:open(f, 0)
    local st = conn:stat(f)
    conn:clunk(f)
    return st
end

function np_prot.file_read(conn, path)
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:open(f, 0)
    local buf_size = 8000
    local offset = 0
    local response = ""
    while (true) do
        local dt = conn:read(f, offset, buf_size)
        if (dt == nil) then
            break
        end
        response = response .. tostring(dt)
        offset = offset + #dt
    end
    conn:clunk(f)
    return response
end

function np_prot.file_create(conn, path, file_name)
    local f, g = conn:newfid(), conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:clone(f, g)
    conn:create(g, file_name, 420, 1)
    conn:clunk(f)
    conn:clunk(g)
end

function np_prot.file_write(conn, path, content)
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:open(f, 1)
    local buf = data.new(content)
    conn:write(f, 0, buf)
    local st = conn:stat(f)
    st.length = #buf
    conn:wstat(f, st)
    conn:clunk(f)
end
