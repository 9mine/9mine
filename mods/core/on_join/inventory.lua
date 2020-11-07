minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    populate_inventory(inventory, "core:connect")
end)

populate_inventory = function(inventory, ...)
    for _, tool in ipairs {...} do
        if inventory:contains_item("main", tool) then
        else
            inventory:add_item("main", tool)
        end
    end
end
