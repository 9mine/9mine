minetest.register_node("core:file_node", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"core_file.png", "core_file.png", "core_file.png", "core_file.png", "core_file.png",
        "core_file.png"},
    inventory_image = "core_file.png",

    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true,
    on_drop = CopyTool.node_on_drop
})
