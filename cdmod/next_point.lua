get_next_point = function(route, direction, current_pos, player)
    if next(route) ~= nil then
        local ip = route[1]
        table.remove(route, 1)
        if known_hosts[ip] ~= nil then
            return known_hosts[ip], ip, direction
        else
            if direction == nil then
                local direction = {x = math.random(), y = math.random(), z = 0}
                local pp = player:get_pos()
                pp.x = pp.x + pp.x * direction.x
                pp.y = pp.y + pp.y * direction.x
                pp.z = 0
                known_hosts[ip] = pp
                return pp, ip, direction
            else
                local v_zero = vector.new(0, 0, 0)
                local next_hop = math.random(5, 20)
                local pp = vector.add(current_pos, vector.multiply(
                                          vector.add(v_zero, next_hop),
                                          direction))
                known_hosts[ip] = pp
                return pp, ip, direction
            end
        end
    else
        return nil
    end
end
