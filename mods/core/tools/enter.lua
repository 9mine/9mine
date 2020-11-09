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
    print(dump(entity))
    local parent_platform = platforms:get_platform(entity.connection_string)
    local child_platform = platform(parent_platform.conn, entity.path, parent_platform.cmdchan)
    local pos = table.copy(player:get_pos())
    pos.y = pos.y + math.random(7, 12)
    pos.x = pos.x + math.random(10)
    pos.z = pos.z + math.random(10)
    child_platform:spawn(pos)
    minetest.chat_send_all("I'm received player with name: " .. player:get_player_name())
end

minetest.register_tool("core:enter", EnterTool)

minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:enter") then
        inventory:add_item("main", "core:enter")
    end
end)
