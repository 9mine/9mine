minetest.register_craft({
    output = "core:kubernetes",
    recipe = {{"core:service_node", "core:kubeconfig"}}
})

minetest.register_craft({
    output = "core:service_node",
    recipe = {{"core:service_node", "core:file_node"}}
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    for index, f in pairs(crafts) do
        f(itemstack, player, old_craft_grid, craft_inv)
    end
end)
