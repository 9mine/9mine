minetest.register_tool("youtube:connect", {
    desription = "Connect to YouTube",
    inventory_image = "youtube_connect.png",
    wield_image = "youtube_connect.png",
    on_use = function(itemstack, player, pointed_thing)
        local player_name = player:get_player_name()

        local formspec = {
            "formspec_version[3]", "size[10,3,false]",
            "field[0.5,0.5;9,1;remote_address;Path to YouTube ctl;tcp!localhost!1000 /youtube]",
            "button_exit[7,1.8;2.5,0.9;spawn_attach;connect]"
        }
        local form = table.concat(formspec, "")
        minetest.show_formspec(player_name, "youtube:connect", form)
    end
})

