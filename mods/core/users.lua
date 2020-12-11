minetest.register_on_prejoinplayer(function(name, ip)
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
    local registry = common.read_registry_index(os.getenv("REGISTRY_ADDR") ~= "" and os.getenv("REGISTRY_ADDR") or
                                                    core_conf:get("REGISTRY_ADDR"))
local parsed_registry = common.parse_registry_index(registry)
local filtered_registries = {}
local filtered_services = {}

local registries_string = ""
local services_string = ""
for index, entry in pairs(parsed_registry) do
    if entry.type == "registry" then
        registries_string = registries_string == "" and entry.service_addr or registries_string .. "," ..
                                entry.service_addr
        table.insert(filtered_registries, entry)
    else
        services_string = services_string == "" and entry.service_addr or services_string .. "," .. entry.service_addr
        table.insert(filtered_services, entry)

    end
end

    minetest.show_formspec(name, "core:global_registry", table.concat(
        {"formspec_version[4]", 
        "size[29,11.5,false]",
         "hypertext[0,0.1;30,1;;<bigger><center>Welcome to 9mine<center><bigger>]",

         "field[0,0;0,0;parsed_registry;;", minetest.formspec_escape(minetest.serialize(parsed_registry)), "]",
         "field[0,0;0,0;filtered_registries;;", minetest.formspec_escape(minetest.serialize(filtered_registries)), "]",
         "field[0,0;0,0;filtered_services;;", minetest.formspec_escape(minetest.serialize(parsed_registry)), "]",
         
         "field[0,0;0,0;registries_string;;", registries_string, "]", 
         "field[0,0;0,0;services_string;;", services_string, "]", 
         
         "tablecolumns[text]", 

         "hypertext[0.5, 0.8; 9, 1;;<big><center>Registries<center><big>]",        
         "field[0.5, 1.5; 6.5, 1;search_registries;;]", "field_close_on_enter[search_registries;false]", 

         "button[7, 1.5; 2.5, 1;button_search_registries; search]",
         "table[0.5, 2.7; 9, 8.3;registries;", registries_string, ";]",

         "hypertext[10, 0.8; 9, 1;;<big><center>Services<center><big>]",   
         "field[10, 1.5; 6.5, 1;search_services;;]", "field_close_on_enter[search_services;false]", 

         "button[16.5, 1.5; 2.5, 1;button_search_services; search]",     
         "table[10, 2.7; 9, 8.3;services;", services_string, ";]", 

         "image[19.5, 1; 9, 4;core_logo.png]",
         "textarea[19.5, 5.5; 9, 5.5;;;Welcome to 9mine Proof of Concept. This project aims to visualize 9p fileservers and interact with them in minecraft-style]"},
        ""))
end

minetest.register_on_joinplayer(function(player, last_login)
    minetest.after(3, common.update_path_hud, player)
    draw_welcome_screen(player)
end)
