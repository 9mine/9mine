minetest.register_node("core:kubernetes", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"core_kubernetes.png", "core_kubernetes.png", "core_kubernetes.png", "core_kubernetes.png", "core_kubernetes.png", "core_kubernetes.png"},
    inventory_image = "core_kubernetes.png",
    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true
})
