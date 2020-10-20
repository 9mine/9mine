minetest.register_tool("core:console", {
    desription = "Attach to Console",
    inventory_image = "core_console.png",
    wield_image = "core_console.png",
    tool_capabilities = {punch_attack_uses = 0, damage_groups = {console = 1}},

    -- on_use = function(itemstack, player, pointed_thing)
    --     local dir = player:get_look_dir()
    --     local dis = vector.multiply(dir, 5)
    --     local pp = player:get_pos()
    --     local fp = vector.add(pp, dis)
    --     fp.y = fp.y + 2
    --     minetest.add_entity(fp, "core:console")
    -- end
    on_use = function(itemstack, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "core:console",
                               "formspec_version[3]size[10,3,false]" ..
                                   "field[0.5,0.5;9,1;host;Remote host;tcp!localhost!1917]" ..
                                   "button_exit[7,1.8;2.5,0.9;connect;connect]")
    end
})
