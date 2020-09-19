check_position = function(route, packet, origin_pos, dest_pos, direction,
                          player, ip, spawned)
    if spawned == nil then
        local hsp = move(origin_pos, dest_pos, nil);
        local current_pos = packet:get_pos()
        local dd = vector.distance(origin_pos, hsp)
        local d = vector.distance(origin_pos, current_pos)

        if d >= dd then
            spawn_entity(dest_pos, ip, "cdmod:host")
            spawned = true
        end
    end

    local current_pos = packet:get_pos()
    local apprx_pos = vector.add(origin_pos, vector.multiply(
                                     vector.subtract(dest_pos, origin_pos), 0.95))
    local dd = vector.distance(origin_pos, apprx_pos)
    local d = vector.distance(origin_pos, current_pos)

    if d >= dd then
        if next(route) == nil then
            packet:remove()
            return
        end
        packet:set_pos(dest_pos)
        local p, ip, direction = get_next_point(route, direction, dest_pos,
                                                player)
        move(dest_pos, p, packet)
        spawned = nil
        minetest.after(0.1, check_position, route, packet, dest_pos, p,
                       direction, player, ip, spawned)
    else
        minetest.after(0.1, check_position, route, packet, origin_pos, dest_pos,
                       direction, player, ip, spawned)

    end

end
