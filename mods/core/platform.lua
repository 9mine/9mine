class 'platform'

function platform:platform(conn, path, cmdchan)
    self.conn = conn
    self.cmdchan = cmdchan
    self.path = path
    self.connection_string = conn.addr .. self.path
end

function platform:readdir()
    local result, content = pcall(readdir, self.conn.attachment, self.path == "/" and "../" or self.path)
    if not result then
        if self.conn:is_alive() then
            minetest.chat_send_all("Connection is alive, but error reading content of directory: " .. content)
            return
        else
            if self.conn:reattach() then
                result, content = pcall(readdir, self.conn, self.path == "/" and "../" or self.path)
                if result then
                    content = content or {}
                end
            end
        end
    else
        self.content = content
    end
    return content
end
