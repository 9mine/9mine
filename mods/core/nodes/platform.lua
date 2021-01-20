minetest.register_node("core:platform", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {
        "default_glass.png", "default_glass.png", "default_glass.png",
        "default_glass.png", "default_glass.png", "default_glass.png"
    },
    use_texture_alpha = true,
    sunlight_propagates = true,
    walkable = true,
    pointable = true,
    diggable = true,
    palette = "core_palette.png",
    paramtype = "none",
    paramtype2 = "color",
    node_box = {type = "regular"},
    on_punch = function(pos, _, puncher)
        local player_name = puncher:get_player_name()
        local player_graph = graphs:get_player_graph(player_name)
        local area = area_store:get_areas_for_pos(pos, false, true)
        local _, value = next(area)
        if not value then
            minetest.chat_send_player(player_name,
                                      "No platform for this position in AreaStore")
            return
        end
        local platform = player_graph:get_platform(value.data)
        platform:show_properties(puncher)
    end
})
