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
    local response = root_cmdchan:execute("mount -A " .. registry_addr .. " /mnt/registry"):gsub("%s+", "")
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
    local attach_string = os.getenv("INFERNO_ADDR") ~= "" and os.getenv("INFERNO_ADDR") or core_conf:get("INFERNO_ADDR")

    -- establish 9p conn
    local connection = connections:get_root_connection()
    if not connection then
        connection = np_over_tcp(attach_string)
        connections:set_root_connection(connection)
        if not connection:attach() then
            error("Failed connecting to the inferno os")
        end
    elseif connection:is_alive() then
        print("Already attached. Connection is alive")
    elseif connection.tcp then
        print("Connection is not alive. Reconnecting")
        connection:reattach()
    else
        if not connection:attach() then
            error("Failed connecting to the inferno os")
        end
    end

    -- check for presence of cmdchan
    local cmdchan_path = tostring(core_conf:get("cmdchan_path"))
    local root_cmdchan = cmdchan(connection, cmdchan_path)
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

spawn_root_platform = function(attach_string, player, last_login, random)
    local player_name = player:get_player_name()
    local connection = connections:get_connection(player_name, attach_string, true)
    if not connection then
        return
    end
    local player_graph = graphs:get_player_graph(player_name) or
                             graphs:add_player_graph(player_graph(player_name), player_name)
    local player_host_node = player_graph:add_host(attach_string)

    local user_cmdchan_path = tostring(core_conf:get("user_cmdchan"))
    local user_cmdchan = cmdchan(connection, user_cmdchan_path)
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
            local result
            if random then
                local result = player:set_pos({
                    x = math.random(-30000, 30000),
                    y = math.random(-30000, 30000),
                    z = math.random(-30000, 30000)
                })
            else
                local result = player:get_pos()
            end
            minetest.after(1.5, function()
                local root_platform = platform(connection, "/", user_cmdchan, player_host_node)
                root_platform:set_player(player_name)
                root_platform.mount_point = "/"
                root_platform.origin_point = result
                root_platform:set_node(player_graph:add_platform(root_platform, nil, player_host_node))
                local point = vector.round(player:get_pos())
                root_platform.root_point = point
                root_platform:spawn(point, player, math.random(0, 255))
                minetest.show_formspec(player_name, "", "")
            end)
        end
    end
end

