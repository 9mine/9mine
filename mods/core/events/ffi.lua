minetest.register_on_player_receive_fields(function(player, formname, fields)
    for index, f in pairs(form_handlers) do 
        local result = f(player, formname, fields)
    end
end)
