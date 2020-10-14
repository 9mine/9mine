check_results = function(player_name, node, search_entity)
    local result, st = pcall(read_stat, node.addr, node.result_path, player_name)
    if result then
        spawn_youtube(st, node.result_p, node.addr, node.result_path)
        search_entity:set_nametag_attributes({text = "Search Video"})
    else
        search_entity:set_pos(node.ctl_p)
        search_entity:set_acceleration({x = 0, y = -4, z = 0})
        search_entity:set_velocity({x = 0, y = 2, z = 0})
        minetest.after(0.5, check_results, player_name, node, search_entity)
    end
end
