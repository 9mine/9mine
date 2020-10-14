youtube_search = function(player, formname, fields)
    minetest.chat_send_player(player:get_player_name(), fields["search_string"])
end
