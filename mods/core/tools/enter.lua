EnterTool = {
    desription = "Enter key",
    inventory_image = "core_enter.png",
    wield_image = "core_enter.png",
    tool_capabilities = {
        punch_attack_uses = 0,
        damage_groups = {
            enter = 1
        }
    }
}

function EnterTool.enter(entity, player)
    local child_platform = platforms:get_platform(entity.addrpath)
    if not child_platform then
        local parent_platform = platforms:get_platform(entity.connection_string)
        child_platform = parent_platform:spawn_child(entity.path)
    end
    player:set_pos(child_platform:get_root_point())
end

minetest.register_tool("core:enter", EnterTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:enter") then
        inventory:add_item("main", "core:enter")
    end
end)
