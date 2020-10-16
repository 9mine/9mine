minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "youtube:grid" then
            youtube_grid(player, formname, fields)
        end
        if formname == "youtube:connect_search" then
            youtube_connect_search(player, formname, fields)
        end
        if formname == "youtube:connect_subs" then
            youtube_connect_subs(player, formname, fields)
        end
        if formname == "youtube:search" then
            youtube_search(player, formname, fields)
        end
    end)
