automount = function()
    -- get string in form of tcp!host!port from ENV or mod.conf
    local attach_string = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or
                              core_conf:get("inferno_address")

    -- establish 9p attachment
    local conn = connections[attach_string]
    if not conn then
        conn = connection(attach_string)
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
    if not root_cmdchan:is_present() then
        error("cmdchan at path " .. cmdchan_path .. " is not available")
    else
        print("cmdchan is available")
    end

    -- mount registry
    root_cmdchan:execute("mount -A tcp!registry.dev.metacoma.io!30100 /mnt/registry")
    os.execute("sleep 2")
    -- get and mount user management service
    local user_management = root_cmdchan:execute("ndb/regquery -n description 'user management'")
    root_cmdchan:execute("mount -A tcp!user.dev.metacoma.io!30101 /n/9mine")
    return root_cmdchan
end

spawn_root_platform = function(attach_string, player, last_login)
    local player_name = player:get_player_name()
    local conn = connections[attach_string]
    if not conn then
        conn = connection(attach_string)
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
    local host_node = platforms:add_host(attach_string)
    local user_cmdchan_path = tostring(core_conf:get("user_cmdchan"))
    local user_cmdchan = cmdchan(conn, user_cmdchan_path)
    if not user_cmdchan:is_present() then
        minetest.chat_send_player(player_name, "cmdchan at path " .. user_cmdchan_path .. " is not available")
    else
        minetest.chat_send_player(player_name, "cmdchan is available")
    end

    if not last_login then
        if platforms:get(attach_string .. "/") then
            local root_platform = platforms:get_platform(attach_string .. "/")
            common.goto_platform(player, root_platform:get_root_point())
        else
            local result = player:set_pos({
                x = math.random(-30000, 30000),
                y = math.random(-30000, 30000),
                z = math.random(-30000, 30000)
            })
            minetest.after(1.5, function(conn, user_cmdchan, host_node, player, player_name)
                local root_platform = platform(conn, "/", user_cmdchan, host_node)
                root_platform:set_player(player_name)
                root_platform.mount_point = "/"
                root_platform:set_node(platforms:add(root_platform))
                root_platform:spawn(vector.round(player:get_pos()), player, math.random(0, 255))
                minetest.show_formspec(player_name, "", "")
            end, conn, user_cmdchan, host_node, player, player_name)
        end
    end
end

