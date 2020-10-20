-- create graph with a name of the player
-- and create a node by name of the player
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if not graphs[name] then
        graphs[name] = graph.open(name)
        graphs[name]:node(name)
    end
end)