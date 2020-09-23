mount_signer = function(signer)
    local path = config.lcmd
    local newuser = config.newuser_addr
    local mount = config.smount
    write_file(path, "mount -A " .. newuser .. " " .. mount)
    local result = read_file("/tmp/file2chan/cmd")
    return result
end

read_file = function(path)
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
    conn:clunk(p)
    conn:clunk(conn.rootfid)
    tcp:close()
    return content
end

write_file = function(path, content)
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

getauthinfo = function(lcmd, signer, name, pass)
    write_file(lcmd,
               "getauthinfo default auth " .. name .. " " .. "'" .. pass .. "'")
    local response = read_file(lcmd)
    return response
end

get_privs = function(rcmd, name)
    write_file(rcmd, "cat /users/" .. name .. "/privs")
    local privs = read_file(rcmd)
    privs = minetest.string_to_privs(privs)
    return privs
end
