youtube_connect = function(player, formname, fields)
    local addr, path, player = connect(player, formname, fields)
    minetest.chat_send_player(player:get_player_name(), "You are connected")
    list_youtube(addr, path, player)
end

