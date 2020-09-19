traceroute = function(host_info, player)
    local route = read_routes(host_info)
    local pos = nil
    local packet = nil
    local host = nil
    local space_route = {}
    for k, v in pairs(route) do
        if known_hosts[v] ~= nil then
            table.insert(space_route, known_hosts[v])
        else
            if pos == nil then
                local pp = player:get_pos()
                host = {x = pp.x + 2, y = pp.y, z = pp.z, t = v}
            else
                host = {
                    x = pos.x + math.random(-20, 20),
                    y = pos.y + math.random(-20, 20),
                    z = 0,
                    t = v
                }
            end
            pos = host
            table.insert(space_route, host)
            known_hosts[v] = host
        end
    end

    if #space_route > 1 then
        print(space_route[0])
        local packet = minetest.add_entity(space_route[1], "cdmod:packet")
        local entity = minetest.add_entity(space_route[1], "cdmod:host")
        entity:set_nametag_attributes({color = "black", text = space_route[1].t})
        entity:set_armor_groups({immortal = 0})
        entity:get_luaentity().ip = space_route[1].t
        move(space_route[1], space_route[2], packet)
        minetest.after(0.1, check_position, space_route, packet, space_route[2],
                       2, nil)
    end
end

