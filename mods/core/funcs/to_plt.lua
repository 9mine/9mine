-- move player to the given position and set 
-- pitch and yaw to be directed to platform
to_plt = function(player, pos)
    pos = pos or player:get_pos()
    player:set_look_horizontal(-(math.pi / 4))
    player:set_look_vertical(0)
    local p = {x = pos.x - 2, y = pos.y + 1, z = pos.z - 2}
    player:set_pos(p)
end
