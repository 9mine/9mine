platform_settings = function(player, fields)
    if fields["quit"] == "true" then return end
    local player_name = player:get_player_name()
    local addr = fields.addr
    local path = fields.path
    local refresh_time = tonumber(fields.refresh_time)
    local plt_node = graphs[player_name]:findnode(hex(addr .. path))
    plt_node.settings.refresh_time = refresh_time
    minetest.chat_send_player(player_name, "Settings saved. Refresh time is " .. refresh_time)
end

