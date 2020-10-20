minetest.register_tool("control9p:console", {
    desription = "Attach to Console",
    inventory_image = "control9p_console.png",
    wield_image = "control9p_console.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {console = 1}},

    on_use = function(itemstack, player, pointed_thing)
        local dir = player:get_look_dir()
        local dis = vector.multiply(dir, 5)
        local pp = player:get_pos()
        local fp = vector.add(pp, dis)
        fp.y = fp.y + 2
        minetest.add_entity(fp, "control9p:console")
    end
})
