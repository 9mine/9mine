minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    if not connections[name] then connections[name] = {} end
    minetest.after(1, automount, player)
end)
