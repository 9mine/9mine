minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "youtube:youtube" then
            youtube(player, formname, fields)
        end
        if formname == "youtube:video_id" then
            video_id(player, formname, fields)
        end
    end)
