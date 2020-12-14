local global_registry = function(player, formname, fields)
    local player_name = player:get_player_name()
    if fields.quit == "true" then
        return
    end
    local selected_entry = fields.selected_entry

    if fields.connect then
        minetest.show_formspec(player:get_player_name(), "core:global_registry", "")
        spawn_root_platform(fields.selected_entry, player, nil, false)
        return
    end

    local parsed_registry = fields.parsed_registry
    local raw_registries = fields.raw_registries
    local raw_services = fields.raw_services
    local filtered_registries = fields.filtered_registries
    local filtered_services = fields.filtered_services
    local registries_string = fields.registries_string
    local services_string = fields.services_string
    local registries_idx = ""
    local services_idx = ""
    local icon, description
    if fields.button_search_registries or fields.key_enter_field == "search_registries" then
        filtered_registries, registries_string = common.filter_registry_by_keyword(minetest.deserialize(raw_registries),
                                                     fields.search_registries)
        filtered_registries = minetest.serialize(filtered_registries)
        selected_entry = nil
    end

    if fields.button_search_services or fields.key_enter_field == "search_services" then
        filtered_services, services_string = common.filter_registry_by_keyword(minetest.deserialize(raw_services),
                                                 fields.search_services)
        filtered_services = minetest.serialize(filtered_services)
        selected_entry = nil
    end

    -- handle click in registry table 
    local event = core.explode_table_event(fields["registries"])
    if event.row ~= 0 then
        local filtered_registries = minetest.deserialize(filtered_registries)
        registries_idx = event.row
        local service = filtered_registries[event.row]
        selected_entry = service.service_addr
        local registry = common.read_registry_index(service.service_addr, player_name)
        registry = common.parse_registry_index(registry)
        local obj, str = common.filter_registry_by_keyword(registry, "")
        raw_services = minetest.serialize(obj)
        filtered_services = raw_services
        services_string = str
        if service.icon then
            icon = common.icon_from_url(service)
        else
            icon = common.icon_from_9p(service)
            if not icon then 
                icon = "core_ns.png"
            end
        end
        description = service.description or dump(service)
    end

    -- handle click in service table 
    local event = core.explode_table_event(fields["services"])
    if event.row ~= 0 then
        local filtered_services = minetest.deserialize(filtered_services)
        services_idx = event.row
        local service = filtered_services[event.row]
        selected_entry = service.service_addr
        if service.icon then
            icon = common.icon_from_url(service)
        else
            icon = common.icon_from_9p(service, player_name)
            if not icon then 
                icon = "core_ns.png"
            end
        end
        description = service.description or dump(service)
    end

    minetest.show_formspec(player_name, "core:global_registry",
        table.concat({"formspec_version[4]", "size[29,11.5,false]",
                      "hypertext[0,0.1;30,1;;<bigger><center>Welcome to 9mine<center><bigger>]",

                      "field[0,0;0,0;parsed_registry;;", minetest.formspec_escape(parsed_registry), "]",
                      "field[0,0;0,0;raw_registries;;", minetest.formspec_escape(raw_registries), "]",
                      "field[0,0;0,0;raw_services;;", minetest.formspec_escape(raw_services), "]",
                      "field[0,0;0,0;filtered_registries;;", minetest.formspec_escape(filtered_registries), "]",
                      "field[0,0;0,0;filtered_services;;", minetest.formspec_escape(filtered_services), "]",
                      selected_entry and "field[0,0;0,0;selected_entry;;" .. minetest.formspec_escape(selected_entry) .. "]" or "", "field[0,0;0,0;registries_string;;", registries_string, "]", 
                      "field[0,0;0,0;services_string;;", services_string, "]", 
                      
                      "tablecolumns[text]",
                      "style[search_registries,search_services;textcolor=black]",
                      "hypertext[0.5, 0.8; 9, 1;;<big><center>Registries<center><big>]",
                      "field[0.5, 1.5; 6.5, 1;search_registries;;]", 
                      "field_close_on_enter[search_registries;false]",

                      "button[7, 1.5; 2.5, 1;button_search_registries;search]", 
                      "table[0.5, 2.7; 9, 8.3;registries;", registries_string, ";", registries_idx, "]",

                      "hypertext[10, 0.8; 9, 1;;<big><center>Services<center><big>]",
                      "field[10, 1.5; 6.5, 1;search_services;;]", 
                      "field_close_on_enter[search_services;false]",

                      "button[16.5, 1.5; 2.5, 1;button_search_services;search]", 
                      "table[10, 2.7; 9, 8.3;services;", services_string, ";]", 
                      "image[19.5, 1; 9, 4;", icon or "core_logo.png", "]",
                      "textarea[19.5, 5.5; 9, 4.5;;;", minetest.formspec_escape(description) or 
                      "Welcome to 9mine Proof of Concept. This project aims to visualize 9p fileservers and interact with them in minecraft-style", "]", 
                      selected_entry and "button[26, 10.3; 2.5, 0.7;connect;connect]" or ""}, ""))

end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:global_registry" then
        global_registry(player, formname, fields)
    end
end)
