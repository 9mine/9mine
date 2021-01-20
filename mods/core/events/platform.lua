local platform_properties = function(player, fields)
    if not (fields.key_enter or fields.save) then return end
    local player_name = player:get_player_name()
    local player_graph = graphs:get_player_graph(player_name)
    local platform = player_graph:get_platform(fields.platform_string)
    platform:set_refresh_time(tonumber(fields.refresh_time))
    -- platform:set_player(fields.player_name)
    if platform:get_color() ~= tonumber(fields.color) then
        platform:colorize(tonumber(fields.color))
    end
    platform.properties.external_handler =
        fields.external_handler == "true" and true or false
    minetest.chat_send_player(player_name, "For " .. fields.platform_string ..
                                  " refresh time is: " .. fields.refresh_time)
end

minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "platform:properties" then
            platform_properties(player, fields)
        end
    end)
