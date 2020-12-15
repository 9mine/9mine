minetest.register_on_prejoinplayer(function(player_name, ip)
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
    register.call_onjoin_funcs(player, last_login)
end)
