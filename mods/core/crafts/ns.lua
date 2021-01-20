craft = function(itemstack, player, old_craft_grid, craft_inv)
    if itemstack:get_name() == "core:ns_node" and old_craft_grid[1]:get_name() ==
        "core:ns_node" and (old_craft_grid[2]:get_name() == "core:file_node" or
        old_craft_grid[2]:get_name() == "core:dir_node") then
        local inventory = player:get_inventory()
        local ns_meta = old_craft_grid[1]:get_meta()
        local ns_ns = ns_meta:get_string("ns")

        -- get info from file 
        local stat_meta = old_craft_grid[2]:get_meta()
        local stat_path = stat_meta:get_string("path")
        local new_ns = ns_ns .. "bind " .. stat_path .. " " .. stat_path
        ns_meta:set_string("ns", new_ns)
        ns_meta:set_string("description", new_ns)
        inventory:add_item("main", old_craft_grid[1])
        itemstack:take_item()
    end
end
register.add_craft_handler("core:ns", craft)
