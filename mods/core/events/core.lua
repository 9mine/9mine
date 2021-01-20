connect = function(player, fields)
    if not (fields.connect or fields.key_enter) then return end
    local player_name = player:get_player_name()
    local attach_string = split_connection_string(
                                           fields.connection_string)
    local connection = connections:get_connection(player_name, attach_string,
                                                  true)
    if not connection then return end
    local player_graph = graphs:get_player_graph(player_name)
    local host_node = player_graph:add_host(attach_string)
    local cmdchan_path = tostring(core_conf:get("cmdchan_path"))
    local root_cmdchan = cmdchan(connection, cmdchan_path)
    if not root_cmdchan:is_present() then
        minetest.chat_send_player(player_name, "cmdchan at path " ..
                                      cmdchan_path .. " is not available")
    else
        minetest.chat_send_player(player_name, "cmdchan is available")
    end

    if player_graph:get_platform(attach_string .. "/") then
        local root_platform = player_graph:get_platform(attach_string .. "/")
        common.goto_platform(player, root_platform:get_root_point())
    else
        local root_platform = platform(connection, "/", root_cmdchan, host_node)
        root_platform:set_player(player:get_player_name())
        root_platform.mount_point = "/"
        local point = vector.round(player:get_pos())
        root_platform.origin_point = point
        root_platform.root_point = point
        root_platform:set_node(player_graph:add_platform(root_platform, nil,
                                                         host_node))
        root_platform:spawn(point, player, math.random(0, 255))
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

minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "core:connect" then connect(player, fields) end
    end)
