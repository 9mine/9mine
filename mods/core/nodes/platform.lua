minetest.register_node("core:platform", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {"default_glass.png", "default_glass.png", "default_glass.png", "default_glass.png", "default_glass.png",
             "default_glass.png"},
    use_texture_alpha = true,
    sunlight_propagates = true,
    walkable = true,
    pointable = true,
    diggable = true,
    node_box = {
        type = "regular"
    },
    on_punch = function(pos, _, puncher)
        local platform = platforms:get_platform(common.get_platform_string(puncher))
        platform:show_properties(puncher)
    end
})
