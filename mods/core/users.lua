minetest.register_on_prejoinplayer(function(name, ip)
    local user_addr = root_cmdchan:execute("ndb/regquery -n user " .. name)
    if not user_addr or user_addr:gsub("%s+", "") == "" then
        root_cmdchan:write("echo -n " .. name .. " >> /n/9mine/user")
    end
    connections:add_player(name)
end)

poll_regquery = function(name, counter, player, last_login)
    if counter > 5 then
        local result, ns_create_output = pcall(np_prot.file_read, root_cmdchan.connection.conn, "/n/9mine/user")
        minetest.kick_player(name, "Error creating NS. Try again later. Log: \n" .. ns_create_output)
    end
    counter = counter + 1
    local user_addr = root_cmdchan:execute("ndb/regquery -n user " .. name):gsub("\n", "")
    local response = root_cmdchan:execute("mount -A " .. user_addr .. " /n/" .. name)
    if response == "" then
        minetest.chat_send_player(name, user_addr .. " mounted")
        minetest.after(2, spawn_root_platform, user_addr, player, last_login)
    else
        minetest.after(2, poll_regquery, name, counter, player, last_login)
    end
end

minetest.register_on_joinplayer(function(player, last_login)
    minetest.after(3, common.update_path_hud, player)
    local name = player:get_player_name()
    local service_list = {}
    local registry = root_cmdchan:execute("cat /mnt/registry/index")
    print(dump(registry))
    for server in registry:gmatch("[^\n]+") do 
        table.insert(service_list, server)
    end
    local service_string = ""
    for index, service in pairs(service_list) do 
        service_string = service_string == "" and service or service_string .. "," .. service
    end
    minetest.show_formspec(name, "core:global_registry",
        table.concat({  "formspec_version[4]", 
                        "size[19.5,11,false]", 
                        "hypertext[0.0,0.0;19.5,1;;<big><center>Select 9p service from the list <center><big>]",
                        "field[0.5,0.5;0,0;server_list;;", minetest.serialize(service_list), "]",
                        "tablecolumns[text]",
                        "table[0.5,1.5;9,9;9p_server;", service_string, ";2]",
                        "image[10,1.5;9,4;core_kubernetes.png]",
                        "textarea[10,6;9,4.5;description;;]"
    }, ""))
end)
