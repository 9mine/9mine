class 'cmdchan'

function cmdchan:cmdchan(conn, cmdchan_path)
    self.attachment = conn.attachment
    self.cmdchan_path = cmdchan_path
end

function cmdchan:is_present()
    local conn = self.attachment
    local f = conn:newfid()
    local result = pcall(np.walk, conn, conn.rootfid, f, self.cmdchan_path)
    if result then
        conn:clunk(f)
    end
    return result
end

function cmdchan:write(command, location)
    local conn = self.attachment
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, self.cmdchan_path)
    conn:open(f, 1)
    local path = location and "cd " .. location .. " ; " or nil
    local cmd = path and path .. command or command
    local buf = data.new(cmd)
    conn:write(f, 0, buf)
    conn:clunk(f)
end

function cmdchan:read()
    local conn = self.attachment
    local f = conn:newfid()
    conn:walk(conn.rootfid, f, self.cmdchan_path)
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

function cmdchan:execute(command, location)
    self:write(command, location)
    return self:read()
end
