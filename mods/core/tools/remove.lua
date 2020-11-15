RemoveTool = {
    desription = "remove file",
    inventory_image = "core_remove.png",
    wield_image = "core_remove.png",
    tool_capabilities = {
        punch_attack_uses = 0,
        damage_groups = {
            remove = 1
        }
    }
}

function RemoveTool.remove(entity, player)
    local directory_entry = platforms:get_entry(entity.entry_string)
    local platform = platforms:get_platform(directory_entry:get_platform_string())
    local cmdchan = platform:get_cmdchan() 
    platform:set_external_handler_flag(true)
    minetest.chat_send_all(cmdchan:execute("rm -rf " .. directory_entry:get_path(), "/"))
    platform:set_external_handler_flag(false)
end

minetest.register_tool("core:remove", RemoveTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:remove") then
        inventory:add_item("main", "core:remove")
    end
end)
