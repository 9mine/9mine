youtube_search = function(player, formname, fields)
    local player_name = player:get_player_name()
    local addr, path, player = plt_by_name(player_name)
    local node = graphs[player_name]:findnode(md5.sumhexa(addr .. path))
    write_file(addr, player_name, node.ctl_path,
               fields["search_string"])
    local search_entity = minetest.get_objects_inside_radius(node.ctl_p, 1)[1]
    search_entity:set_nametag_attributes({text = "Searching . . . "})
    search_entity:set_acceleration({x = 0, y = -2, z = 0})
    search_entity:set_velocity({x = 0, y = 1, z = 0})
    minetest.after(0.5, check_results, player_name, node, search_entity)
    minetest.chat_send_player(player_name, fields["search_string"])
end
