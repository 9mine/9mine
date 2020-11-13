minetest.register_node("core:dir_node", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"core_dir.png", "core_dir.png", "core_dir.png", "core_dir.png", "core_dir.png", "core_dir.png"},
    inventory_image = "core_dir.png",
    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true,
    on_drop = CopyTool.node_on_drop
})
