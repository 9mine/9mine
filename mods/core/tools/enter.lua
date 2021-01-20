EnterTool = {
    desription = "Enter key",
    inventory_image = "core_enter.png",
    wield_image = "core_enter.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {enter = 1}}
}

function EnterTool.enter(entity, player, player_name)
    local player_graph = graphs:get_player_graph(player_name)
    local directory_entry = player_graph:get_entry(entity.entry_string)
    if directory_entry.stat.qid.type ~= 128 then return end
    local child_platform = player_graph:get_platform(directory_entry.entry_string)
    if not child_platform then
        local parent_platform = player_graph:get_platform(directory_entry.platform_string)
        parent_platform:spawn_child(directory_entry.path, player)
        return
    end
    common.goto_platform(player, child_platform:get_root_point())

end

minetest.register_tool("core:enter", EnterTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player:get_inventory()
    if not inventory:contains_item("main", "core:enter") then
        inventory:add_item("main", "core:enter")
    end
end)
