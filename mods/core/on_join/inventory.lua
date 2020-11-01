minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    populate_inventory(inventory, "core:attach",
                       "core:enter", "core:spawn_console", "core:read", "core:write", "core:edit")
end)
