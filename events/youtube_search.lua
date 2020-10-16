youtube_search = function(player, formname, fields)
    local ss = fields["search_string"]
    if (ss == "") or (not ss) then return end
    
    local player_name = player:get_player_name()
    local addr, path, player = plt_by_name(player_name)
    local node = graphs[player_name]:findnode(hex(addr .. path))

    file_write(addr, node.ctl_path, player_name, ss)

    local req = get_entity(node.ctl_p)
    req:set_nametag_attributes({text = "Searching . . . "})
    req:set_acceleration({x = 0, y = -2, z = 0})
    req:set_velocity({x = 0, y = 1, z = 0})
    req:get_luaentity().search_string = ss

    minetest.after(0.5, check_results, player_name, node, req)
end
