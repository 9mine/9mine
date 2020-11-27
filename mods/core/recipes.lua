-- service node 
minetest.register_craft({
    output = "core:service_node",
    recipe = {{"core:service_node", "core:file_node"}}
})

minetest.register_craft({
    output = "core:ns_node",
    recipe = {{"core:ns_node", "core:dir_node"}}
})

minetest.register_craft({
    output = "core:ns_node",
    recipe = {{"core:ns_node", "core:file_node"}}
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    register.call_craft_handlers(itemstack, player, old_craft_grid, craft_inv)
end)
