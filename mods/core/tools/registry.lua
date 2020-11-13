RegistryTool = {
    desription = "Show registry",
    inventory_image = "core_registry.png",
    wield_image = "core_registry.png"
}

function RegistryTool.handle_form(player, fields)
    minetest.chat_send_all(dump(fields))
end

function RegistryTool.get_registries_string(player)
    local attachment = platforms:get_platform(common.get_platform_string(player)):get_attachment()
    local registry_path = os.getenv("REGISTRY_PATH") ~= "" and os.getenv("REGISTRY_PATH") or
                              core_conf:get("registry_path")
    local result, content = pcall(readdir, attachment, registry_path)
    local registries_string
    if result then
        for key, entry in pairs(content) do
            if registries_string then
                registries_string = registries_string .. "," .. entry.name
            else
                registries_string = entry.name
            end
        end
    end
    return registries_string
end

function RegistryTool.on_use(itemstack, player)
    local player_name = player:get_player_name()
    local registries_string = RegistryTool.get_registries_string(player)
    if not registries_string then
        minetest.chat_send_all("Error getting list of registries")
        return
    end

    minetest.show_formspec(player_name, "core:registry",
        table.concat({"formspec_version[4]", "size[15,12.5,false]", "label[5,0.5;Add registry to inventory]",
                      "field[0.5,1;9,1;search;;]", "button[10.5,1;4,1;search;search]",
                      "textlist[0.5,2.5;14,8;registry;" .. registries_string .. "]",
                      "button_exit[12,11;2.5,1;registry;Add]"}, ""))
end

minetest.register_tool("core:registry", RegistryTool)
minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:registry") then
        inventory:add_item("main", "core:registry")
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:registry" then
        RegistryTool.handle_form(player, fields)
    end
end)
