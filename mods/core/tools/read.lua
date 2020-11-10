ReadTool = {
    desription = "Read file",
    inventory_image = "core_read.png",
    wield_image = "core_read.png",
    tool_capabilities = {
        punch_attack_uses = 0,
        damage_groups = {
            read = 1
        }
    }
}

function ReadTool.read(entity, player)
    local attachment = platforms:get_platform(common.get_platform_string(player)):get_attachment()
    local content = np_prot.file_read(attachment, entity.path)

    minetest.show_formspec(player:get_player_name(), "core:file_content",
        table.concat({"formspec_version[3]", "size[13,13,false]", "textarea[0.5,0.5;12.0,12.0;;;",
                      minetest.formspec_escape(content), "]"}, ""))
    return
end

minetest.register_tool("core:read", ReadTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:read") then
        inventory:add_item("main", "core:read")
    end
end)
