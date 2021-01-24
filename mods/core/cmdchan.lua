--- utilize cmdchan
class 'cmdchan'

--- constructor
-- @tparam connection connection connection object
-- @tparam string cmdchan_path path to the cmdchan
function cmdchan:cmdchan(connection, cmdchan_path)
    self.connection = connection
    self.cmdchan_path = cmdchan_path
end

--- check if cmdchan is present at provided to costructor path
-- @treturn bool present cmdchan or not
function cmdchan:is_present()
    local conn = self.connection.conn
    if not conn then return end
    local result, f = pcall(np.newfid, conn)
    if not result then return end
    result = pcall(np.walk, conn, conn.rootfid, f, self.cmdchan_path)
    if result then conn:clunk(f) end
    return result
end

--- write to the cmdchan
-- @tparam string command command to be written to cmdchan
-- @tparam string location path of platform from which command is executed
-- @treturn nil
function cmdchan:write(command, location)
    local conn = self.connection.conn
    local f = conn:newfid()
    print("Write " .. command .. " to " .. self.cmdchan_path)
    conn:walk(conn.rootfid, f, self.cmdchan_path)
    conn:open(f, 1)
    local path = location and "cd " .. location .. " ; " or nil
    local cmd = path and path .. command or command
    local buf = data.new(cmd .. "\n")
    conn:write(f, 0, buf)
    conn:clunk(f)
end

--- read response from cmdchan
-- @tparam string path path to file where response is located
-- @treturn string response from cmdchan
function cmdchan:read(path)
    local conn = self.connection.conn
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

--- execute (write and read) to cmdchan
-- @tparam string command command to be written to cmdchan
-- @tparam string location path of platform from which command is executed
-- @treturn string response from cmdchan
function cmdchan:execute(command, location)
    local tmp_file = "/n/cmdchan/cmdchan_output"
    command = command .. " > " .. tmp_file .. " >[2=1]"
    pcall(cmdchan.write, self, command, location)
    return select(2, pcall(cmdchan.read, self, tmp_file))
end

--- show response from cmdchan in formspec
-- @tparam string response response from cmdchan
-- @tparam string player_name name of the player
-- @treturn nil
function cmdchan.show_response(response, player_name)
    minetest.show_formspec(player_name, "cmdchan:response",
                           table.concat({"formspec_version[3]", "size[13,13,false]",
        "textarea[0.5, 0.5; 12.0, 11.0;;;", minetest.formspec_escape(response), "]",
        "button_exit[10, 11.8;2.5,0.7;close;close]"}, ""))
end
