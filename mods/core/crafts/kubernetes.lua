minetest.register_craft({
    output = "core:kubernetes",
    recipe = {
        {"core:service_node", "core:kubeconfig" }
    }
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    if itemstack:get_name() == "core:kubernetes" and old_craft_grid[1]:get_name() == "core:service_node" and old_craft_grid[2]:get_name() == "core:kubeconfig" then 
        
        -- get info from craft items
        local item_meta = old_craft_grid[1]:get_meta()
        local service = item_meta:get_string("service")
        
        -- configure kubernetes
        local kubernetes = itemstack:get_meta()
        kubernetes:set_string("service", service)
        kubernetes:set_string("description", service)
        minetest.chat_send_all("Handler for kubernetes recipe " .. service)   
    end
end)