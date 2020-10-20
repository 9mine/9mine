minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    populate_inventory(inventory, "control9p:console", "control9p:attach",
                       "control9p:enter", "control9p:write")
end)
