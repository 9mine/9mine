show_settings = function(pos, player)
    local meta = minetest.get_meta(pos)
    local addr = meta:get_string("addr")
    local path = meta:get_string("path")
    local graph = graphs[player:get_player_name()] 
    local plt_node = graph:findnode(hex(addr .. path))
    local is_plt = plt_node and plt_node.plt
    if not is_plt then
        send_warning(player:get_player_name(), "No platform found")
        return
    end
    local refresh_time = plt_node.settings.refresh_time

    minetest.show_formspec(player:get_player_name(), "platform:settings", table.concat(
                                   {
                "formspec_version[3]", "size[10,6,false]",
                "label[4,0.5;Platform settings]",
                "field[0.5,1;9,0.7;refresh_time;Refresh Frequency;" .. refresh_time .. "]",
                "button_exit[0.5,4.8;2.5,0.7;close;close]",
                "button_exit[3.8,4.8;2.5,0.7;close;reset]",
                "button_exit[7,4.8;2.5,0.7;close;save]",
                "field[0,0;0,0;addr;;" .. addr .. "]",
                "field[0,0;0,0;path;;" .. path .. "]",
            }, ""))
end