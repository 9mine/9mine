connect = function(player, fields)
    -- if "attach" button was not pressed by mouse or by enter key, return
    if not (fields.spawn_attach or fields.key_enter) then return end

    local player_name = player:get_player_name()
    local remote_address = fields.remote_address
    if not remote_address or (remote_address == "") then
        send_warning(player_name, "No connection string provided")
        return
    end
    -- parse provided string and handle errors
    local host_info, addr, path = parse_remote_address(remote_address)

    if not host_info or not addr or not path then
        send_warning(player_name,
                     "Connection string parser returned no information")
        return
    end
    if not host_info.host or not host_info.port then
        send_warning(player_name, "Hostname or port number is not provided")
        return
    end

    -- retieve graph for player and check if provided host already exists
    local addr_node = graph:findnode(addr)

    if not addr_node then
        addr_node = graph:node(addr, {host_info = host_info, addr = addr})
        local root_node = graph:findnode("mt-root")
        graph:edge(root_node, addr_node)
    end

    -- retrieve 9p attached connection or create new if not exists
    local conn = connections[player_name][addr]

    if not conn then
        print("Connecting to " .. addr .. " . . . ")
        local tcp = socket:tcp()
        local _, err = tcp:connect(host_info.host, host_info.port, "*", 0)

        if (err ~= nil) then
            minetest.chat_send_player(player_name, "Connection error to " ..
                                          addr .. ": " .. err)
            return
        end
        print("Connected")
        conn = np.attach(tcp, "root", "")
        connections[player_name][addr] = conn
    else
        minetest.chat_send_player(player_name,
                                  "Already connected to host " .. addr)
    end
    return addr, path, player
end
