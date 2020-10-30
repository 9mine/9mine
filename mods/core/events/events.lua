minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "core:spawn_attach" then
            spawn_attach(player, fields)
        end
        if formname == "core:spawn_console" then
            spawn_console(player, formname, fields)
        end
        if formname == "core:console" then
            console(player, formname, fields)
        end
        if formname == "platform:settings" then
            platform_settings(player, fields, formname)
        end
    end)
