-- handle connection string received from attach tool
youtube_grid = function(player, formname, fields)
    local pn = player:get_player_name()
    local ID, rsp = next(fields)
    local a, p, player = plt_by_name(pn)
    file_create(a, "/subs", pn, ID)
    minetest.chat_send_player(pn, "Video " .. ID .. " sent for processing")
    minetest.close_formspec(pn, formname)
end

