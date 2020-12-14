minetest.register_on_prejoinplayer(function(player_name, ip)
    print("ndb/regquery -n user " .. player_name .. "> /tmp/cmdchan_output >[2=1]")
    root_cmdchan:execute("mkdir /n/" .. player_name)
    local user_addr = root_cmdchan:write("ndb/regquery -n user " .. player_name .. "> /tmp/cmdchan_output >[2=1]")
    if not graphs:get_player_graph(player_name) then
        graphs:add_player_graph(player_graph(player_name), player_name)
    end
    connections:add_player(player_name)
end)

poll_regquery = function(name, counter, player, last_login)
    if counter > 10 then
        local result, ns_create_output = pcall(np_prot.file_read, root_cmdchan.connection.conn, "/n/9mine/user")
        minetest.kick_player(name, "Error creating NS. Try again later. Log: \n" .. ns_create_output)
    end
    counter = counter + 1
    local user_addr = root_cmdchan:execute("ndb/regquery -n user " .. name):gsub("\n", "")
    local response = root_cmdchan:execute("mount -A " .. user_addr .. " /n/" .. name)
    if response == "" then
        minetest.chat_send_player(name, user_addr .. " mounted")
        minetest.after(2, spawn_root_platform, user_addr, player, last_login, true)
    else
        minetest.after(2, poll_regquery, name, counter, player, last_login)
    end
end

minetest.register_on_joinplayer(function(player, last_login)
    minetest.after(3, common.update_path_hud, player)
    -- draw_welcome_screen(player)
    local player_name = player:get_player_name()
    common.show_wait_notification(player_name, "Please, wait.\nThe namespace is creating.")
    minetest.after(2, function()
        local user_addr = root_cmdchan:read("/tmp/cmdchan_output"):gsub("\n", "")
        if not user_addr or user_addr:gsub("%s+", "") == "" then
            root_cmdchan:write("echo -n " .. player_name .. " >> /n/9mine/user")
            local counter = 1
            minetest.after(2, poll_regquery, player_name, counter, player, last_login)
        else
           local result = root_cmdchan:execute("mount -A " .. user_addr .. " /n/" .. player_name)
           if result == "" then 
                minetest.chat_send_player(player_name, user_addr .. " mounted")
                minetest.after(2, spawn_root_platform, user_addr, player, last_login)
           else
            minetest.kick_player(player_name, "Error mounting NS. Try again later. Log: \n" .. result)
           end
        end
    end)
end)
