minetest.register_node("youtube:video", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {
        "youtube_video.png", "youtube_video.png", "youtube_video.png",
        "youtube_video.png", "youtube_video.png", "youtube_video.png"
    },
    use_texture_alpha = true,
    stack_max = 1,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true,
    on_drop = function(itemstack, dropper, pos)
        local item_meta = itemstack:get_meta()
        local id = item_meta:get_string("ID")
        local item = itemstack:take_item(1)
        local tx = id .. ".png"
        local pos = dropper:get_pos()
        local p = table.copy(pos)
        local dir = dropper:get_look_dir()
        dir.x = dir.x * 2.9
        dir.y = dir.y * 2.9 + 2
        dir.z = dir.z * 2.9
        p.x = p.x + dir.x
        p.y = p.y + dir.y
        p.z = p.z + dir.z
        local e = minetest.add_entity(p, "youtube:subs")
        e:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            nametag = id,
            nametag_color = "black"
        })

        return itemstack
    end
})
