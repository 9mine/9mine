minetest.register_craft({
    type = "shapeless",
    output = "core:kubernetes",
    recipe = {
        "core:fileserver",
        "core:kubeconfig",
    },
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    if itemstack:get_name() == "core:kubernetes" and old_craft_grid[1]:get_name() == "core:fileserver" and old_craft_grid[2]:get_name() == "core:kubeconfig" then 
        
        -- get info from craft items
        local item_meta = old_craft_grid[1]:get_meta()
        local connection_string = item_meta:get_string("connection_string")
        
        -- configure kubernetes
        local kubernetes = itemstack:get_meta()
        kubernetes:set_string("connection_string", connection_string)
        kubernetes:set_string("description", connection_string)
        minetest.chat_send_all("Handler for kubernetes recipe " .. connection_string)   
    end
end)