platform_settings = function(player, fields)
    player_name = player:get_player_name()
    addr = fields.addr
    path = fields.path 
    refresh_time = fields.refresh_time
    local plt_node = graphs[player_name]:findnode(hex(addr .. path))
    plt_node.settings.refresh_time = refresh_time
    send_warning(player_name, "Settings saved")
end

