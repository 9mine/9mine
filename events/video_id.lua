video_id = function(player, formname, fields)
    local video_id = fields["video_id"]
    if not video_id then return end
    minetest.chat_send_player(player:get_player_name(), "\n" .. video_id .. "\n")
    local thumbnails = {}
    for id in string.gmatch(video_id, "[^ ]+") do
        local thumb_name = save_thumbnail(id)
        table.insert(thumbnails, thumb_name)
    end
    show_thumbnails(player:get_player_name(), thumbnails)
end

