minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "core:connect" then
        connect(player, fields)
    end
    if formname == "core:spawn_console" then
        spawn_console(player, formname, fields)
    end
    if formname == "core:console" then
        console(player, formname, fields)
    end
    if formname == "platform:properties" then
        platform_properties(fields)
    end
    if formname == "core:edit" or formname == "core:write" then
        edit(player, fields)
    end
end)
