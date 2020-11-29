minetest.register_on_prejoinplayer(function(name, ip)
    local user_addr = root_cmdchan:execute("ndb/regquery -n user " .. name)
    if not user_addr or user_addr:gsub("%s+", "") == "" then
        root_cmdchan:write("echo -n " .. name .. " >> /n/9mine/user")
        os.execute("sleep 2")
        user_addr = root_cmdchan:execute("ndb/regquery -n user " .. name)
    end
    user_addr = user_addr:gsub("\n", "")
    print(root_cmdchan:execute("mkdir /n/" .. name))
    print("mount -A " .. user_addr .. " /n/" .. name)
    local response = root_cmdchan:execute("mount -A " .. user_addr .. " /n/" .. name)
    return  response == "" and user_addr .. " mounted" or response
end)

