minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    populate_inventory(inventory, "youtube:connect_search", "youtube:arrow", "youtube:connect_subs")
end)