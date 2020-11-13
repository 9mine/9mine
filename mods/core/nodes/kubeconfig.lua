minetest.register_node("core:kubeconfig", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"core_kubeconfig.png", "core_kubeconfig.png", "core_kubeconfig.png", "core_kubeconfig.png", "core_kubeconfig.png", "core_kubeconfig.png"},
    inventory_image = "core_kubeconfig.png",
    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true
})


minetest.register_on_joinplayer(function(player)
    local inventory = player.get_inventory(player)
    if not inventory:contains_item("main", "core:kubeconfig") then
        -- inventory:add_item("main", "core:kubeconfig")
    end
end)
