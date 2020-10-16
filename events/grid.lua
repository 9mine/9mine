youtube_grid = function(player, formname, fields)
    local player_name = player:get_player_name()
    local ID, _ = next(fields)
    if ID == "quit" then return end
    add_video_item(ID, player)
    send_warning(player_name, "Video ID " .. ID .. " added to inventory]")
end

