send_warning = function(player_name, warning)
    minetest.chat_send_player(player_name, warning)
    minetest.show_formspec(player_name, "youtube:warning", table.concat(
                               {
            "formspec_version[3]", "size[10,2,false]",
            "label[0.5,0.5;" .. warning .. "]",
            "button_exit[7,1.0;2.5,0.7;close;close]"
        }, ""))
end
