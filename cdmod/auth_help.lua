read_file = function(connection, path)
    local tcp = socket:tcp()
    local connection, err = tcp:connect("getauth", 1917)
    if (err ~= nil) then
        print("dump of error newest .. " .. dump(err))
        print("Connection error")
        return
    end
    local conn = np.attach(tcp, "dievri", "")
    local p = conn:newfid()
    np:walk(conn.rootfid, p, path)
    conn:open(p, 0)
    local READ_BUF_SIZ = 8000
    local offset = 0
    local content = nil
    local dt = conn:read(p, offset, READ_BUF_SIZ)
    content = tostring(dt)
    if dt ~= nil then offset = offset + #dt end
    while (true) do
        dt = conn:read(p, offset, READ_BUF_SIZ)
        if (dt == nil) then break end
        content = content .. tostring(dt)
        offset = offset + #(tostring(dt))
    end
    print("content of cmd (for password) is " .. content)
    conn:clunk(p)
    conn:clunk(conn.rootfid)
    tcp:close()
    return content
end

write_file = function(connection, path, content)
    local tcp = socket:tcp()
    local connection, err = tcp:connect("getauth", 1917)
    if (err ~= nil) then
        print("dump of error newest .. " .. dump(err))
        print("Connection error")
        return
    end
    local conn = np.attach(tcp, "dievri", "")
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, path)
    conn:open(f, 1)
    local buf = data.new(content)
    local n = conn:write(f, 0, buf)
    if n ~= #buf then
        error("test: expected to write " .. #buf .. " bytes but wrote " .. n)
    end
    conn:clunk(f)
    conn:clunk(conn.rootfid)
    tcp:close()
end

create_file = function(parent_path, filename)
    local tcp = socket:tcp()
    local connection, err = tcp:connect("getauth", 1917)
    if (err ~= nil) then
        print("dump of error newest .. " .. dump(err))
        print("Connection error")
        return
    end
    local conn = np.attach(tcp, "dievri", "")
    local f, g = conn:newfid(), conn:newfid()
    conn:walk(conn.rootfid, f, parent_path)
    conn:clone(f, g)
    conn:create(g, filename, 420, 1)
    conn:clunk(f)
    conn:clunk(g)
    conn:clunk(conn.rootfid)
    tcp:close()
end

get_privileges = function()
    local privileges = minetest.settings:get("default_privs")
    return minetest.string_to_privs(privileges)
end
