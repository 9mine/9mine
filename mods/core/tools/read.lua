ReadTool = {
    desription = "Read file",
    inventory_image = "core_read.png",
    wield_image = "core_read.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {read = 1}}
}

function ReadTool.read(entity, player, player_name, player_graph)
    local directory_entry = player_graph:get_entry(entity.entry_string)
    local conn = player_graph:get_platform(common.get_platform_string(player))
                     :get_conn()
    local response, content = pcall(np_prot.file_read, conn,
                                    directory_entry.path)
    if not response then
        minetest.chat_send_player(player_name, content)
        return
    else
        minetest.show_formspec(player_name, "core:file_content",
                               table.concat(
                                   {
                "formspec_version[3]", "size[13,13,false]",
                "textarea[0.5,0.5;12.0,12.0;;;",
                minetest.formspec_escape(content), "]"
            }, ""))
        return
    end
end

minetest.register_tool("core:read", ReadTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:read") then
        inventory:add_item("main", "core:read")
    end
end)
