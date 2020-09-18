traceroute = function(host_info, path, player, known_hosts)
    local tcp = socket:tcp()
    local connection, err = tcp:connect(host_info["host"], host_info["port"])
    if (err ~= nil) then error("Connection error: " .. dump(err)) end
    local conn = np.attach(tcp, "dievri", "")
    local f = conn:newfid()

    np:walk(conn.rootfid, f, path)
    conn:open(f, 0)
    local statistics = conn:stat(f)
    local buf = conn:read(f, 0, statistics.length - 1)
    local content = tostring(buf)

    conn:clunk(f)
    tcp:close()
    local file = io.open("test.txt", "w")
    file:write(content)
    file:close()
    local route = {}
    for line in io.lines("test.txt") do
        if string.match(line, "^[ ]*[%d]+") ~= nil and
            string.match(line, "%d+%.%d+%.%d+%.%d+") then
            table.insert(route, string.match(line, "%d+%.%d+%.%d+%.%d+"))
        end
    end

    local pos = nil
    local packet = nil
    local space_route = {}
    for k, v in pairs(route) do
        if known_hosts[v] ~= nil then
            table.insert(space_route, known_hosts[v])
        else
            local rx = math.random(-20, 20)
            local ry = math.random(-20, 20)
            local rz = math.random(-20, 20)

            local host = {x = rx, y = ry, z = rz, t = v}

            if pos ~= nil then
                host = {
                    x = pos.x + host.x,
                    y = pos.y + host.y,
                    z = pos.z,
                    t = v
                }
            end
            pos = host
            table.insert(space_route, host)
            known_hosts[v] = host
        end
    end

    if #space_route > 1 then
        local packet = minetest.add_entity(space_route[1], "cdmod:packet")
        local entity = minetest.add_entity(space_route[1], "cdmod:host")
        entity:set_nametag_attributes({color = "black", text = space_route[1].t})
        entity:set_armor_groups({immortal = 0})
        entity:get_luaentity().ip = space_route[1].t
        move(space_route[1], space_route[2], packet)
        minetest.after(0.1, check_position, space_route, packet, space_route[2], 2, nil)
    end
end
