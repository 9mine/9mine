-- handle connection string received from attach tool
youtube_grid = function(player, formname, fields)
    local pn = player:get_player_name()
    local texture, rsp = next(fields)
    local a, p, player = plt_by_name(pn)
    file_create(a, "/subs", pn, texture)
    minetest.chat_send_player(pn, "Video " .. texture .. " sent for processing")
    -- spawn_video(player, texture)
    minetest.close_formspec(pn, formname)
end

