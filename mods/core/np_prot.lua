--- basic 9p interactions
class 'np_prot'

--- read stat from path specified
-- @tparam conn conn 9p connection
-- @tparam string path path of file for stat to be read
-- @treturn table stat
function np_prot.stat_read(conn, path)
    local f = conn:newfid()
    if path == "/" then
        conn:clone(conn.rootfid, f)
    else
        conn:walk(conn.rootfid, f, path)
    end
    conn:open(f, 0)
    local st = conn:stat(f)
    conn:clunk(f)
    return st
end

--- read file from path specified
-- @tparam conn conn 9p connection
-- @tparam string path path to the file to be read
-- @treturn string file content
function np_prot.file_read(conn, path)
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:open(f, 0)
    local buf_size = 8000
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

--- create file at path with given name
-- @tparam conn conn 9p connection
-- @tparam string path path to the directory in which file will be created
-- @tparam string file_name name of the file to be created
-- @treturn nil
function np_prot.file_create(conn, path, file_name)
    local f, g = conn:newfid(), conn:newfid()
    if path == "/" then
        conn:clone(conn.rootfid, f)
    else
        conn:walk(conn.rootfid, f, path)
    end
    conn:clone(f, g)
    conn:create(g, file_name, 420, 1)
    conn:clunk(f)
    conn:clunk(g)
end

--- write to the file specified
-- @tparam conn conn 9p connection
-- @tparam string path path to the file to be edited
-- @tparam string content new content of the file
-- @treturn nil
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
