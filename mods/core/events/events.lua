minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "control9p:spawn_attach" then
            spawn_attach(player, formname, fields)
        end
        if formname == "control9p:console" then
            console(player, formname, fields)
        end
    end)
