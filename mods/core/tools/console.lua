minetest.register_tool("core:spawn_console", {
    desription = "Spawn Console Cube",
    inventory_image = "core_console.png",
    wield_image = "core_console.png",

    on_use = function(itemstack, player, pointed_thing)
        local player_name = player:get_player_name()
        minetest.show_formspec(player_name, "core:spawn_console",
                               "formspec_version[3]size[10,3,false]" ..
                                   "field[0.5,0.5;9,1;remote_address;Remote host;tcp!localhost!1917]" ..
                                   "button_exit[7,1.8;2.5,0.9;spawn_attach;connect]")
    end
})
