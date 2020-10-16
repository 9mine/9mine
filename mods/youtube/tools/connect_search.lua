minetest.register_tool("youtube:connect_search", {
    description = "Connect to YouTube",
    inventory_image = "youtube_connect.png",
    wield_image = "youtube_connect.png",
    on_use = function(itemstack, player, pointed_thing)
        minetest.show_formspec(player:get_player_name(),
                               "youtube:connect_search", table.concat(
                                   {
                "formspec_version[3]", "size[10,3,false]",
                "field[0.5,0.5;9,1;remote_address;Path to YouTube ctl;tcp!mt-local!1917 /youtubefs]",
                "button_exit[7,1.8;2.5,0.9;spawn_attach;connect]"
            }, ""))
    end
})

