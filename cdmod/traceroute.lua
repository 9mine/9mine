traceroute = function(host_info, player)
    local route = read_routes(host_info)
    local pos = nil
    local packet = nil
    local host = nil

    if #route > 1 then
        local pp, ip, direction = get_next_point(route, nil, nil, player)
        local packet = spawn_entity(pp, nil, "cdmod:packet")
        spawn_entity(pp, ip, "cdmod:host")
        known_hosts[ip] = pp
        local next_pp, ip, direction = get_next_point(route, direction, pp, player)
        move(pp, next_pp, packet)
        print("in tarceroute the ip is .." .. ip)
        minetest.after(0.1, check_position, route, packet, pp, next_pp,
                       direction, player, ip, nil)
    end
end

get_next_point = function(route, direction, current_pos, player)
    if next(route) ~= nil then
        print("get next point ... " .. dump(route[1]))
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
                known_hosts[ip] = pp
                return pp, ip, direction
            else
                local v_zero = vector.new(0, 0, 0)
                local next_hop = math.random(10, 15)
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
