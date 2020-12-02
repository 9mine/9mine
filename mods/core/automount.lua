poll_user_management = function(root_cmdchan)
    print("Polling user management . . .")
    print(root_cmdchan:execute("mount -A tcp!registry.dev.metacoma.io!30100 /mnt/registry"))
    local user_management = root_cmdchan:execute("ndb/regquery -n description 'user management'"):gsub("\n", "")
    if user_management:match(".*!.*!.*") then
        print(user_management)
        print("mount -A " .. user_management .. " /n/9mine")
        print(root_cmdchan:execute("mount -A " .. user_management .. " /n/9mine"))
    else
        minetest.after(3, poll_user_management, root_cmdchan)
    end
end

mount_registry = function(root_cmdchan, registry_addr)
    local response = root_cmdchan:execute("mount -A ".. registry_addr .. " /mnt/registry"):gsub("%s+", "")
    if response == "" then
        local user_management = root_cmdchan:execute("ndb/regquery -n description 'user management'"):gsub("\n", "")
        if user_management:match(".*!.*!.*") then
            print(user_management)
            print("mount -A " .. user_management .. " /n/9mine")
            print(root_cmdchan:execute("mount -A " .. user_management .. " /n/9mine"))
        else
            minetest.after(3, poll_user_management, root_cmdchan)
        end
    else
        print("Registry mount failed. Retry")
        minetest.after(3, mount_registry, root_cmdchan, registry_addr)
    end
end

automount = function()
    -- get string in form of tcp!host!port from ENV or mod.conf
    local attach_string = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or
                              core_conf:get("inferno_address")

    -- establish 9p attachment
    local conn = connections:get_root_connection()
    if not conn then
        conn = connection(attach_string)
        connections:set_root_connection(conn)
        if not conn:attach() then
            error("Failed connecting to the inferno os")
        end
    elseif conn:is_alive() then
        print("Already attached. Connection is alive")
    elseif conn.tcp then
        print("Connection is not alive. Reconnecting")
        conn:reattach()
    else
        if not conn:attach() then
            error("Failed connecting to the inferno os")
        end
    end

    -- check for presence of cmdchan
    local cmdchan_path = tostring(core_conf:get("cmdchan_path"))
    local root_cmdchan = cmdchan(conn, cmdchan_path)
    connections:set_root_cmdchan(root_cmdchan)
    if not root_cmdchan:is_present() then
        error("cmdchan at path " .. cmdchan_path .. " is not available")
    else
        print("cmdchan is available")
    end

    -- mount registry
    print(root_cmdchan:execute("mkdir -p /n/9mine /mnt/registry"))
    local registry_addr = os.getenv("REGISTRY_ADDR") ~= "" and os.getenv("REGISTRY_ADDR") or
                              core_conf:get("REGISTRY_ADDR")
    mount_registry(root_cmdchan, registry_addr)

    return root_cmdchan
end

spawn_root_platform = function(attach_string, player, last_login)
    local player_name = player:get_player_name()
    local conn = connections:get_connection(player_name, attach_string)
    if not conn then
        conn = connection(attach_string)
        connections:add_connection(player_name, conn)
        if not conn:attach() then
            return
        end
    elseif conn:is_alive() then
        minetest.chat_send_player(player_name, "Already attached. Connection is alive")
    elseif conn.tcp then
        minetest.chat_send_player(player_name, "Connection is not alive. Reconnecting")
        conn:reattach()
    else
        conn:attach()
    end
    local player_graph = graphs:get_player_graph(player_name) or
                             graphs:add_player_graph(player_graph(player_name), player_name)
    local player_host_node = player_graph:add_host(attach_string)

    local user_cmdchan_path = tostring(core_conf:get("user_cmdchan"))
    local user_cmdchan = cmdchan(conn, user_cmdchan_path)
    if not user_cmdchan:is_present() then
        minetest.chat_send_player(player_name, "cmdchan at path " .. user_cmdchan_path .. " is not available")
    else
        minetest.chat_send_player(player_name, "cmdchan is available")
    end

    if not last_login then
        if player_graph:get_node(attach_string .. "/") then
            local root_platform = player_graph:get_platform(attach_string .. "/")
            common.goto_platform(player, root_platform:get_root_point())
        else
            local result = player:set_pos({
                x = math.random(-30000, 30000),
                y = math.random(-30000, 30000),
                z = math.random(-30000, 30000)
            })
            minetest.after(1.5, function(conn, user_cmdchan, player_host_node, player, player_name)
                local root_platform = platform(conn, "/", user_cmdchan, player_host_node)
                root_platform:set_player(player_name)
                root_platform.mount_point = "/"
                root_platform:set_node(player_graph:add_platform(root_platform, nil, player_host_node))
                root_platform:spawn(vector.round(player:get_pos()), player, math.random(0, 255))
                minetest.show_formspec(player_name, "", "")
            end, conn, user_cmdchan, player_host_node, player, player_name)
        end
    end
end

