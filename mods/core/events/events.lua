minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "core:spawn_attach" then
            spawn_attach(player, formname, fields)
        end
        if formname == "core:console" then
            spawn_attach(player, formname, fields)
        end
    end)
