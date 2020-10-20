goto_plt = function(path, player)
    local name = player:get_player_name()
    local plt_node = graphs[name]:findnode(hex(path))
    local is_plt = plt_node and plt_node.plt
    if is_plt then
        to_plt(player, plt_node.root)
        return true 
    else
        return false
    end
end
