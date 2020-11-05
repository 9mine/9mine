platform_settings = function(player, fields, formname)
    if fields["quit"] == "true" then return end
    local player_name = player:get_player_name()
    local addr = fields.addr
    local path = fields.path
    local refresh_time = tonumber(fields.refresh_time)
    local plt_node = graph:findnode(hex(addr .. path))
    plt_node.settings.refresh_time = refresh_time
    minetest.chat_send_player(player_name, "Settings saved. Refresh time is " .. refresh_time)
    minetest.close_formspec(player_name, formname)
end

