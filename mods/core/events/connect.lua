connect = function(player, fields)
    if not (fields.connect or fields.key_enter) then
        return
    end
    local attach_string, attach_path = split_connection_string(fields.connection_string)
    local conn = connections[attach_string]
    if not conn then
        conn = connection(attach_string)
        conn:attach()
    elseif conn:is_alive() then
        minetest.chat_send_all("Already attached. Connection is alive")
    elseif conn.tcp then
        minetest.chat_send_all("Connection is not alive. Reconnecting")
        conn:reattach()
    else
        conn:attach()
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
