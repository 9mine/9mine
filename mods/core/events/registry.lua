local global_registry = function(player, formname, fields)
    minetest.chat_send_player(player:get_player_name(), dump(fields))
    if fields.connect == "connect" then
        local event = core.explode_table_event(fields["9p_server"])
        local services = minetest.deserialize(fields.services)
        spawn_root_platform(fields.selected_server, player)
        return
    end
    if fields.quit == "true" then
        draw_welcome_screen(player)
        return
    end
    local images = {}
    table.insert(images, "core_fileserver.png")
    table.insert(images, "core_platforms.png")
    table.insert(images, "core_mendel.png")
    table.insert(images, "core_console.png")
    table.insert(images, "core_ns.png")
    table.insert(images, "core_kubernetes.png")
    table.insert(images, "core_registry.png")

    if not fields.services then
        return
    end
    local event = core.explode_table_event(fields["9p_server"])
    local services = minetest.deserialize(fields.services)
    minetest.show_formspec(player:get_player_name(), "core:global_registry",
        table.concat({"formspec_version[4]", "size[19,11,false]",
                      "hypertext[0.0,0.0;19.5,1;;<big><center>Select 9p service from the list <center><big>]",
                      "field[0.5,0.5;0,0;services;;", minetest.formspec_escape(minetest.serialize(services)), "]",
                      "field[0.5,0.5;0,0;service_string;;", fields.service_string, "]",
                      "field[0.5,0.5;0,0;selected_server;;", services[event.row].service_addr, "]", 
                      "tablecolumns[text]",
                      "field[0.5,1;6.5,1;search;;]", 
                      "field_close_on_enter[search;false]",
                      "button[7,1;2.5,1;button_search;search]", 
                      "table[0.5,2.2;9,8.3;9p_server;", fields.service_string, ";", event.row, "]", 
                      "image[10,1;8.5,4;", images[event.row % 7 == 0 and 7 or event.row % 7], "]",
                      "textarea[10,5.5;8.5,4.1;desc;;", services[event.row].description or "No description provided. Look at dump of service: \n" .. dump(services[event.row]), "]",
                      "button_exit[16,9.8;2.5,0.7;connect;connect]"}, ""))

    return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:global_registry" then
        global_registry(player, formname, fields)
    end
end)
