youtube_connect = function(player, formname, fields)
    local name = player:get_player_name()
    local addr, path, player = connect(player, formname, fields)
    if not (addr and path and player) then return end
    if not goto_plt(addr .. path, player) then
        list_youtube(addr, path, player)
    end
end

