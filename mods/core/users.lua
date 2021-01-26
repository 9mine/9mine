minetest.register_on_prejoinplayer(function(player_name)
    if not graphs:get_player_graph(player_name) then
        graphs:add_player_graph(player_graph(player_name), player_name)
    end
    connections:add_player(player_name)
end)

minetest.register_on_joinplayer(function(player, last_login)
    minetest.after(3, common.update_path_hud, player)
    register.call_onjoin_funcs(player, last_login)
end)
