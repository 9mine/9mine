RegistryTool = {
    desription = "Show registry",
    inventory_image = "core_registry.png",
    wield_image = "core_registry.png"
}

function RegistryTool.handle_form(player, fields)
    if fields.button_search or fields.key_enter_field == "search" then
        local form = RegistryTool.get_form(fields.registries_string, fields.search)
        minetest.show_formspec(player:get_player_name(), "core:registry", form)
    elseif fields.button_add and fields.service ~= "" then
        local item = ItemStack("core:service_node")
        local item_meta = item:get_meta()
        item_meta:set_string("service", fields.service)
        item_meta:set_string("description", fields.service)
        player:get_inventory():add_item("main", item)
        common.show_info(player:get_player_name(), "Service " .. fields.service .. " was added to your inventory.")
    end
    minetest.chat_send_all(dump(fields))
end

-- reads REGISTRY_PATH and returns all registries as comma-separated list
function RegistryTool.get_registries_string(player)
    local attachment = platforms:get_platform(common.get_platform_string(player)):get_attachment()
    local registry_path = os.getenv("REGISTRY_PATH") ~= "" and os.getenv("REGISTRY_PATH") or
                              core_conf:get("registry_path")
    local index_path = registry_path == "/" and registry_path .. "index" or registry_path .. "/" .. "index"
    local response, services = pcall(np_prot.file_read, attachment, index_path)
    local registries_string
    if response then
        for service in services:gmatch("[^\n]+") do
            if registries_string then
                registries_string = registries_string .. "," .. service:match("[^ ]+")
            else
                registries_string = service:match("[^ ]+")
            end
        end
    end
    return registries_string
end

-- returns formspec. If provided with search parameter, filters 
-- registries list just to those who match
function RegistryTool.get_form(registries_string, search)
    local new_registries_string = ""
    if search and search ~= "" then
        for registry in registries_string:gmatch("[^,]+") do
            if registry:match(search) then
                if new_registries_string == "" then
                    new_registries_string = registry
                else
                    new_registries_string = new_registries_string .. "," .. registry
                end
            end
        end
    else
        new_registries_string = registries_string
    end

    return table.concat({"formspec_version[4]", "size[15,8,false]", "label[5,0.5;Add registry to inventory]",
                         "field[0,0;0,0;registries_string;;" .. minetest.formspec_escape(registries_string) .. "]",
                         "field[0.5,1;9,1;search;;]", "field_close_on_enter[search;false]",
                         "button[10.5,1;4,1;button_search;search]",
                         "dropdown[0.5,2.5;14,1;service;" .. new_registries_string .. ";1;]",
                         "button_exit[12,6.5;2.5,1;button_add;add]"}, "")
end

function RegistryTool.on_use(itemstack, player)
    local player_name = player:get_player_name()
    local registries_string = RegistryTool.get_registries_string(player)
    if not registries_string then
        minetest.chat_send_all("Error getting list of registries")
        return
    end
    minetest.show_formspec(player_name, "core:registry", RegistryTool.get_form(registries_string))
end

minetest.register_tool("core:registry", RegistryTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:registry") then
        inventory:add_item("main", "core:registry")
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:registry" then
        RegistryTool.handle_form(player, fields)
    end
end)
