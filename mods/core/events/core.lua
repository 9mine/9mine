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
    local host_node = platforms:add_host(attach_string)
    local cmdchan_path = tostring(core_conf:get("cmdchan_path"))
    local root_cmdchan = cmdchan(conn, cmdchan_path)
    if not root_cmdchan:is_present() then
        minetest.chat_send_all("cmdchan at path " .. cmdchan_path .. "is not available")
    else
        minetest.chat_send_all("cmdchan is available")
    end
    if platforms:get(attach_string .. "/") then
        local root_platform = platforms:get_platform(attach_string .. "/")
        root_platform:spawn_path(attach_path, player)
    else
        local root_platform = platform(conn, "/", root_cmdchan, host_node)
        root_platform:set_node(platforms:add(root_platform))
        root_platform:spawn(vector.round(player:get_pos()))
        if attach_path ~= "/" then
            root_platform:spawn_path(attach_path, player)
        else
            common.goto_platform(player, root_platform:get_root_point())
        end
       
    end

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

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:connect" then
        connect(player, fields)
    end
end)
