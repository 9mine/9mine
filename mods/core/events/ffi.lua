minetest.register_on_player_receive_fields(function(player, formname, fields)
    register.call_form_handlers(player, formname, fields)
end)