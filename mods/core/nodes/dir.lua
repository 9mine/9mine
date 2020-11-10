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
    on_drop = function(itemstack, dropper, pos)
        local item_meta = itemstack:get_meta()
        local name = item_meta:get_string("name")
        local addr = item_meta:get_string("addr")
        local path = item_meta:get_string("path")
        itemstack:take_item(1)
        local pos = dropper:get_pos()
        local p = table.copy(pos)
        local dir = dropper:get_look_dir()
        dir.x = dir.x * 2.9
        dir.y = dir.y * 2.9 + 2
        dir.z = dir.z * 2.9
        p.x = p.x + dir.x
        p.y = p.y + dir.y
        p.z = p.z + dir.z
        local e = minetest.add_entity(p, "core:dir")
        e:get_luaentity().addr = addr
        e:set_properties({
            nametag = name,
            nametag_color = "black"
        })
        e:set_acceleration({
            x = 0,
            y = -9.81,
            z = 0
        })
        minetest.after(2, on_drop, e, addr, path, dropper:get_player_name(), name, "cp -r")
        return itemstack
    end
})
