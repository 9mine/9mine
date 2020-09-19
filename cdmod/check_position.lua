check_position = function(route, packet, dest_pos, route_entry, spawned)
    local prev = route[route_entry - 1]
    if spawned == nil then
        local hsp = move(prev, dest_pos, nil);
        local current_pos = packet:get_pos()
        local dd = vector.distance(prev, hsp)
        local d = vector.distance(prev, current_pos)

        if d >= dd then
            local entity = minetest.add_entity(route[route_entry], "cdmod:host")
            entity:set_nametag_attributes(
                {color = "black", text = route[route_entry].t})
            entity:set_armor_groups({immortal = 0})
            entity:get_luaentity().ip = route[route_entry].t
            spawned = true
        end
    end

    local current_pos = packet:get_pos()
    local apprx_pos = vector.add(prev, vector.multiply(
                                     vector.subtract(dest_pos, prev), 0.95))
    local dd = vector.distance(prev, apprx_pos)
    local d = vector.distance(prev, current_pos)

    if d >= dd then
        if route_entry == #route then
            packet:set_velocity({x = 0, y = 0, z = 0})
            packet:set_pos(dest_pos)
            packet:remove()
            return
        end
        packet:set_pos(dest_pos)

        local pos = dest_pos
        route_entry = route_entry + 1
        dest_pos = route[route_entry]
        move(pos, dest_pos, packet)
        spawned = nil
        minetest.after(0.1, check_position, route, packet, dest_pos,
                       route_entry, spawned)
    else
        minetest.after(0.1, check_position, route, packet, dest_pos,
                       route_entry, spawned)

    end

end
