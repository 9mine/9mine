RemoveTool = {
    desription = "remove file",
    inventory_image = "core_remove.png",
    wield_image = "core_remove.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {remove = 1}}
}

function RemoveTool.remove(entity, player)
    local player_name = player:get_player_name()
    local player_graph = graphs:get_player_graph(player_name)
    local directory_entry = player_graph:get_entry(entity.entry_string)
    local platform = player_graph:get_platform(directory_entry:get_platform_string())
    local cmdchan = platform:get_cmdchan()
    platform:set_external_handler_flag(true)
    minetest.chat_send_player(player_name,
                              cmdchan:execute("rm -rf " .. directory_entry:get_path(), "/"))
    platform:set_external_handler_flag(false)
end

minetest.register_tool("core:remove", RemoveTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:remove") then
        inventory:add_item("main", "core:remove")
    end
end)
