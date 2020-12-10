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

draw_welcome_screen = function(player)
    local name = player:get_player_name()
    local registry = root_cmdchan:execute("cat /mnt/registry/index")
    local services = common.parse_registry_index(registry)
    local service_string = ""
    for index, service in pairs(services) do
        service_string = service_string == "" and service.service_addr or service_string .. "," .. service.service_addr
    end
    minetest.show_formspec(name, "core:global_registry", table.concat(
        {   "formspec_version[4]", 
            "size[19,11,false]",
            "hypertext[0.0,0.0;19.5,1;;<big><center>Select 9p service from the list <center><big>]",
            "field[0.5,0.5;0,0;original_services;;", minetest.formspec_escape(minetest.serialize(services)), "]", 
            "field[0.5,0.5;0,0;services;;", minetest.formspec_escape(minetest.serialize(services)), "]", 
            "field[0.5,0.5;0,0;service_string;;", service_string, "]", 
            "tablecolumns[text]", "field[0.5,1;6.5,1;search;;]", 
            "field_close_on_enter[search;false]",
            "button[7,1;2.5,1;button_search;search]", 
            "table[0.5,2.2;9,8.3;9p_server;", service_string, ";]",
            "image[10,1;8.5,4;core_logo.png]",
            "textarea[10,5.5;9,4.5;;;Welcome to 9mine Proof of Concept. This project aims to visualize 9p fileservers and interact with them in minecraft-style]"},
        ""))
end

minetest.register_on_joinplayer(function(player, last_login)
    minetest.after(3, common.update_path_hud, player)
    draw_welcome_screen(player)
end)
