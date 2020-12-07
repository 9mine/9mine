class 'buffer'

function buffer:buffer(conn, path)
    -- tcp 9p socket connection
    self.conn = conn
    self.path = path
    self.fid = nil
    self.fid_open = false
    self.offset = 0
    self.content = {}
end

function buffer:open()
    local conn = self.conn
    local path = self.path
    local fid = conn:newfid()
    conn:walk(conn.rootfid, fid, self.path == "/" and "./" or self.path)
    conn:open(fid, 0)
    self.fid = fid
    self.offset = 0
    self.fid_open = true
end

function buffer:is_open()
    return self.fid_open
end

function buffer:close()
    self.conn:clunk(self.fid)
    self.fid_open = false
end

function buffer:read_next()
    if not self:is_open() then
        self:open()
    end
    local buf_size = 4096
    local read_data = self.conn:read(self.fid, self.offset, buf_size)
    local dir = tostring(read_data)
    if not read_data then
        self:close()
        return nil
    else
        self.offset = self.offset + #(tostring(read_data))
        return dir
    end
end

function buffer:parse_raw(raw_content, append)
    local content_chunk = {}
    while true do
        local st = self.conn:getstat(data.new(raw_content))
        if st == nil then
            if append then
                return self.content
            else
                return content_chunk
            end
        end
        if append then
            table.insert(self.content, st)
        else
            table.insert(content_chunk, st)
        end
        raw_content = raw_content:sub(st.size + 3)
        if (#raw_content == 0) then
            break
        end
        if append then
            return self.content
        else
            return content_chunk
        end
    end
end
