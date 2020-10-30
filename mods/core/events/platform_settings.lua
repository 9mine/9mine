platform_settings = function(player, fields)
    local player_name = player:get_player_name()
    local addr = fields.addr
    local path = fields.path 
    local refresh_time = tonumber(fields.refresh_time)
    local plt_node = graphs[player_name]:findnode(hex(addr .. path))
    local old_refresh_time = plt_node.settings.refresh_time
    if old_refresh_time == 0 then 
        plt_node.settings.refresh_time = refresh_time
        minetest.after(refresh_time, platform_refresh, plt_node, addr, path, player_name)
    end 
    send_warning(player_name, "Settings saved")
end

