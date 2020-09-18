minetest.register_node("cdmod:platform", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {
        "default_glass.png", "default_glass.png", "default_glass.png",
        "default_glass.png", "default_glass.png", "default_glass.png"
    },
    use_texture_alpha = false,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true,
    node_box = {type = "regular"}
})
