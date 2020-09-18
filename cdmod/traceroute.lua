traceroute = function(host_info, player)
    local tcp = socket:tcp()
    local connection, err = tcp:connect(host_info["host"], host_info["port"])
    if (err ~= nil) then error("Connection error: " .. dump(err)) end
    local conn = np.attach(tcp, "dievri", "")
    local f = conn:newfid()

    np:walk(conn.rootfid, f, host_info["path"])
    conn:open(f, 0)
    local statistics = conn:stat(f)
    local READ_BUF_SIZ = 4096
    local offset = 0
    local content = nil
    local data = conn:read(f, offset, READ_BUF_SIZ)
    content = tostring(data)
    -- pprint(data)
    offset = offset + #data
    while (true) do
        data = conn:read(f, offset, READ_BUF_SIZ)

        if (data == nil) then break end
        content = content .. tostring(data)
        offset = offset + #(tostring(data))
    end

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
    local host = nil
    local space_route = {}
    for k, v in pairs(route) do
        if known_hosts[v] ~= nil then
            table.insert(space_route, known_hosts[v])
        else
            if pos == nil then
                local pp = player:get_pos()
                print(dump(pp))
                host = {x = pp.x + 2, y = pp.y, z = 0, t = v}
            else
                host = {
                    x = pos.x + math.random(-15, 15),
                    y = pos.y + math.random(-15, 15),
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
