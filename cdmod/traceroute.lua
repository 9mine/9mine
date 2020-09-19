traceroute = function(host_info, player)
    local route = read_routes(host_info)
    local pos = nil
    local packet = nil
    local host = nil

    -- for k, v in pairs(route) do
    --     if known_hosts[v] ~= nil then
    --         table.insert(space_route, known_hosts[v])
    --     else
    --         if pos == nil then
    --             local pp = player:get_pos()
    --             host = {p = {x = pp.x + 2, y = pp.y, z = pp.z}, t = v}
    --         else
    --             host = {
    --                 p = {
    --                     x = pos.x + math.random(-20, 20),
    --                     y = pos.y + math.random(-20, 20),
    --                     z = 0
    --                 },
    --                 t = v
    --             }
    --         end
    --         pos = host
    --         table.insert(space_route, host)
    --         known_hosts[v] = host
    --     end
    -- end

    if #route > 1 then
        local ip = route[1]
        local p_p = nil
        if known_hosts[ip] ~= nil then
            p_p = known_hosts[ip]
        else
            local direction = {x = math.random(), y = math.random(), z = 0}
            local pp = player:get_pos()
            pp.x = pp.x + pp.x * direction.x
            pp.y = pp.y + pp.y * direction.x
            p_p = pp
        end
        spawn_entity(p_p, nil, "cdmod:packet")
        spawn_entity(p_p, ip, "cdmod:host")
        known_hosts[ip] = p_p
       -- move(pp, packet)

    -- minetest.after(0.1, check_position, route, packet, 2, nil)
    end
end

-- TODO:
-- 0. Get directional vector
-- 1. get IP
-- 2. check if position for IP is known
-- 3. if known, move to than position
-- 4. If now known, generate new random position based on directonal vector.
