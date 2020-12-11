local global_registry = function(player, formname, fields)
    local parsed_registry = fields.parsed_registry
    local filtered_registries = fields.filtered_registries
    local filtered_services = fields.filtered_services
    local registries_string = fields.registries_string
    local services_string = fields.services_string
    local registries_idx = ""
    local services_idx = ""
    local icon, description
    local event = core.explode_table_event(fields["registries"])
    if event.row ~= 0 then
        local filtered_registries = minetest.deserialize(filtered_registries)
        registries_idx = event.row
        local service = filtered_registries[event.row]
        local registry = common.read_registry_index(service.service_addr)
        registry = common.parse_registry_index(registry)
        local obj, str = common.filter_registry_by_keyword(registry, "")
        filtered_services = minetest.serialize(obj)
        services_string = str
        if not texture.exists(common.hex(service.service_addr) .. ".png", "registry") then
            texture.download(service.icon, service.icon:match("https://") and true or false,
                common.hex(service.service_addr) .. ".png", "registry")
        end
        icon = common.hex(service.service_addr) .. ".png"
        description = service.description
    end

    minetest.show_formspec(player:get_player_name(), "core:global_registry",
        table.concat({"formspec_version[4]", "size[29,11.5,false]",
                      "hypertext[0,0.1;30,1;;<bigger><center>Welcome to 9mine<center><bigger>]",

                      "field[0,0;0,0;parsed_registry;;", minetest.formspec_escape(parsed_registry), "]",
                      "field[0,0;0,0;filtered_registries;;", minetest.formspec_escape(filtered_registries), "]",
                      "field[0,0;0,0;filtered_services;;", minetest.formspec_escape(filtered_services), "]",

                      "field[0,0;0,0;registries_string;;", registries_string, "]", 
                      "field[0,0;0,0;services_string;;", services_string, "]", 
                      
                      "tablecolumns[text]",

                      "hypertext[0.5, 0.8; 9, 1;;<big><center>Registries<center><big>]",
                      "field[0.5, 1.5; 6.5, 1;search_registries;;]", 
                      "field_close_on_enter[search_registries;false]",

                      "button[7, 1.5; 2.5, 1;button_search_registries; search]", 
                      "table[0.5, 2.7; 9, 8.3;registries;", registries_string, ";", registries_idx, "]",

                      "hypertext[10, 0.8; 9, 1;;<big><center>Services<center><big>]",
                      "field[10, 1.5; 6.5, 1;search_services;;]", 
                      "field_close_on_enter[search_services;false]",

                      "button[16.5, 1.5; 2.5, 1;button_search_services; search]", 
                      "table[10, 2.7; 9, 8.3;services;", services_string, ";]", 
                      "image[19.5, 1; 9, 4;", icon or "core_logo.png", "]",
                      "textarea[19.5, 5.5; 9, 5.5;;;", description or "Welcome to 9mine Proof of Concept. This project aims to visualize 9p fileservers and interact with them in minecraft-style",
                      "]"}, ""))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:global_registry" then
        global_registry(player, formname, fields)
    end
end)
