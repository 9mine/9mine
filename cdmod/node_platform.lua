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
    node_box = {type = "regular"},
    on_punch = function(pos, node, puncher, pointed_thing)
        local wielded_item = puncher:get_wielded_item()
        local capabilities = wielded_item:get_tool_capabilities()
        if capabilities.damage_groups.flip == 1 then
            -- local wielded_item = inventory.get_wielded_item()
            local node_meta = minetest.get_meta(pos)
            local c = minetest.deserialize(node_meta:get_string("corner"))
            local corner_info = minetest.get_meta({x = c.x, y = c.y, z = c.z})
            local empty_string = corner_info:get_string("empty")
            delete_platform(c.x, c.y, c.z, c.s, c.o)
        end
        if capabilities.damage_groups.wipe == 1 then
            -- local wielded_item = inventory.get_wielded_item()
            local node_meta = minetest.get_meta(pos)
            local c = minetest.deserialize(node_meta:get_string("corner"))
            local corner_info = minetest.get_meta({x = c.x, y = c.y, z = c.z})
            local empty_string = corner_info:get_string("empty")
            wipe_platform(c.x, c.y, c.z, c.s, c.o)
        end
    end
})

