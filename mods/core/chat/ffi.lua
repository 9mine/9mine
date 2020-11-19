minetest.register_on_chat_message(function(player_name, message)
    for index, f in pairs(functions) do 
        local result = f(player_name, message)
    end
end)