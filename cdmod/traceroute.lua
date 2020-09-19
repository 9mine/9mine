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
        local next_pp, ip, direction = get_next_point(route, direction, pp,
                                                      player)
        move(pp, next_pp, packet)
        minetest.after(0.1, check_position, route, packet, pp, next_pp,
                       direction, ip, player, nil)
    end
end
