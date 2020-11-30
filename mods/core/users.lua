minetest.register_on_prejoinplayer(function(name, ip)
    local user_addr = root_cmdchan:execute("ndb/regquery -n user " .. name)
    if not user_addr or user_addr:gsub("%s+", "") == "" then
        root_cmdchan:write("echo -n " .. name .. " >> /n/9mine/user")
    end
end)

minetest.register_on_joinplayer(function(player, last_login)
    local name = player:get_player_name()
    local user_addr = root_cmdchan:execute("ndb/regquery -n user " .. name):gsub("\n", "")
    root_cmdchan:execute("mkdir /n/" .. name)
    if root_cmdchan:execute("mount -A " .. user_addr .. " /n/" .. name) == "" then
        minetest.chat_send_player(name, user_addr .. " mounted")
        minetest.after(2, spawn_root_platform, user_addr, player, last_login)
    else
        common.show_wait_notification(name, "Please, wait.\nThe namespace is creating.")
        minetest.after(1, function(name)
            local user_addr = root_cmdchan:execute("ndb/regquery -n user " .. name):gsub("\n", "")
            local response = root_cmdchan:execute("mount -A " .. user_addr .. " /n/" .. name)
            if response == "" then
                minetest.show_formspec(name, "", "")
                minetest.chat_send_player(name, user_addr .. " mounted")
                minetest.after(2, spawn_root_platform, user_addr, player, last_login)
            else
                minetest.kick_player(name, response .. "\n. Try again later")
            end
        end, name)
    end
end)

