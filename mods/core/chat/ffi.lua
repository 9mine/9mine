minetest.register_on_chat_message(function(player_name, message)
    for _, f in pairs(functions) do
        f(player_name, message)
    end
end)
