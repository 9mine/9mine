connect = function(player, fields)
    if not (fields.connect or fields.key_enter) then
        return
    end
    local attach_string, attach_path = split_connection_string(fields.connection_string)
    local conn = connections[attach_string]
    if not conn then
        conn = connection(attach_string)
        if not conn:attach() then
            return
        end
    elseif conn:is_alive() then
        minetest.chat_send_all("Already attached. Connection is alive")
    elseif conn.tcp then
        minetest.chat_send_all("Connection is not alive. Reconnecting")
        conn:reattach()
    else
        conn:attach()
    end
    local cmdchan_path = tostring(core_conf:get("cmdchan_path"))
    local root_cmdchan = cmdchan(conn, cmdchan_path)
    if not root_cmdchan:is_present() then
        minetest.chat_send_all("cmdchan at path " .. cmdchan_path .. "is not available")
    else
        minetest.chat_send_all("cmdchan is available")
    end

    local pos = player:get_pos()

    local root_platform = platform(conn, attach_path, root_cmdchan)
    local content = root_platform:readdir()
    root_platform:set_size()
    root_platform:draw(pos)
    minetest.chat_send_all(dump(content))
    minetest.after(3, platform.enlarge, root_platform)
    minetest.after(6, platform.enlarge, root_platform)
end

split_connection_string = function(connection_string)
    local strings = {}
    for token in connection_string:gmatch("[^ ]+") do
        table.insert(strings, token)
    end
    local attach_string = strings[1]
    -- set initial path if not present
    local attach_path = strings[2] ~= nil and strings[2]:match("^/.*$") or "/"
    return attach_string, attach_path
end
