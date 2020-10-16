generate_subs = function(entity, player)
    local player_pos = player:get_pos()
    local player_name = player:get_player_name()
    local plt_node = minetest.find_node_near(player_pos, 7, "control9p:plt", true)
    if not plt_node then
        add_video_item(entity:get_luaentity().id, player) 
        entity:remove()
        minetest.show_formspec(player_name, "youtube:warning", table.concat(
                                   {
                "formspec_version[3]", "size[10,2,false]",
                "label[0.5,0.5;No speech2text proccessing unit found]",
                "button_exit[7,1.0;2.5,0.7;close;close]"
            }, ""))
    end
end
