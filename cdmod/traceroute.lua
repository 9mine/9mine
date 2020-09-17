traceroute = function(host_info, path)
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
        local rx = math.random(-15, 15)
        local ry = math.random(-15, 15)
        local rz = math.random(-15, 15)

        local entity_pos = {x = rx, y = ry, z = rz}
        local entity = minetest.add_entity(entity_pos, "cdmod:host")
        entity:set_nametag_attributes({color = "black", text = v})
        entity:set_armor_groups({immortal = 0})
        entity:get_luaentity().ip = v
        table.insert(space_route, entity_pos)
    end
    print(dump(space_route[1]))
    if #space_route > 1 then
        local packet = minetest.add_entity(space_route[1], "cdmod:packet")
        move(space_route[1], space_route[2], packet)
        minetest.after(0.2, check_position, space_route, packet, space_route[2],
                       2)
    end
end
