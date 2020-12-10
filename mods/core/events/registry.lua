local global_registry = function(player, formname, fields)
    if fields.connect == "connect" and fields.selected_server ~= "" then
        spawn_root_platform(fields.selected_server, player)
        return
    end
    if fields.quit == "true" and not fields.connect == "connect" then
        return
    end
    if not fields.services then
        return
    end
    local event = core.explode_table_event(fields["9p_server"])
    local filtered_services = minetest.deserialize(fields.services)
    local service_string = fields.service_string
    if event.row ~= 0 then 
        local service = filtered_services[event.row]
        if not texture.exists(service.service_addr .. ".png", "registry") then 
            texture.download(service.url, false, service.service_addr .. ".png", "registry")
        end
    end
    -- is search field is not empty then use just those fields, that match
    if fields.search ~= "" then 
        service_string = ""
        filtered_services = {}
        local original_services = minetest.deserialize(fields.original_services)
        local s = fields.search
        for index, service in pairs(original_services) do 
            local flag = false
            for key, value in pairs(service) do 
                if key:match(s) or value:match(s) then 
                    flag = true 
                end
            end
            if flag then 
            table.insert(filtered_services, service)
            end
        end
        for index, service in pairs(filtered_services) do 
            service_string = service_string == "" and service.service_addr or service_string .. "," .. service.service_addr
        end
    end

    -- if search fields was used without entering text then restore full list 
    if (fields.key_enter_field == "search" and fields.search == "") or (fields.button_search == "search" and fields.search == "") then 
        filtered_services = minetest.deserialize(fields.original_services)
        for index, service in pairs(filtered_services) do 
            service_string = service_string == "" and service.service_addr or service_string .. "," .. service.service_addr
        end
    end
     minetest.show_formspec(player:get_player_name(), "core:global_registry",
        table.concat({"formspec_version[4]", "size[19,11,false]",
                      "hypertext[0.0,0.0;19.5,1;;<big><center>Select 9p service from the list <center><big>]",
                      "field[0.5,0.5;0,0;original_services;;", minetest.formspec_escape(fields.original_services), "]",
                      "field[0.5,0.5;0,0;services;;", minetest.formspec_escape(minetest.serialize(filtered_services)), "]",
                      "field[0.5,0.5;0,0;service_string;;", service_string, "]",
                      "field[0.5,0.5;0,0;selected_server;;", event.row ~= 0 and filtered_services[event.row].service_addr or "", "]", 
                      "tablecolumns[text]",
                      "field[0.5,1;6.5,1;search;;]", 
                      "field_close_on_enter[search;false]",
                      "button[7,1;2.5,1;button_search;search]", 
                      "table[0.5,2.2;9,8.3;9p_server;", service_string, ";", event.row or "", "]", 
                      "image[10,1;8.5,4;", event.row ~= 0 and filtered_services[event.row].service_addr .. ".png" or "core_logo.png", "]",
                      "textarea[10,5.5;8.5,4.1;desc;;", event.row ~= 0 and filtered_services[event.row].description or "No description provided. Look at dump of service: \n" .. dump(event.row ~= 0 and filtered_services[event.row] or ""), "]",
                      "button_exit[16,9.8;2.5,0.7;connect;connect]"}, ""))

    return true
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:global_registry" then
        global_registry(player, formname, fields)
    end
end)
