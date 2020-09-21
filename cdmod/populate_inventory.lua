populate_inventory = function(inventory, ...)
    for i, v in ipairs {...} do
        if inventory:contains_item("main", v) then
        else
            inventory:add_item("main", v)
        end
    end
end
