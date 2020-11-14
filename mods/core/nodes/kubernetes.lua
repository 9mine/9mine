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

function ServiceNode.on_drop(itemstack, dropper, pos)
    local item_meta = itemstack:get_meta()
    -- local name = item_meta:get_string("name")
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
    local stat_entity = minetest.add_entity(p, "core:stat")
    stat_entity:set_acceleration({
        x = 0,
        y = -9.81,
        z = 0
    })
    -- minetest.after(2, CopyTool.on_drop, stat_entity, name, dropper:get_player_name(), "cp -r")
    return itemstack
end