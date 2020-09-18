minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "cdmod:connect" then
            if (fields["conn_string"] == nil) then end
            local conn_string = fields["conn_string"]
            local t = {}
            for str in string.gmatch(conn_string, "[^!]+") do
                table.insert(t, str)
            end
            local conn_type = t[1]
            local conn_host = t[2]
            local conn_port = tonumber(t[3])

            local host_info = {
                type = conn_type,
                host = conn_host,
                port = conn_port
            }

            local tcp = socket:tcp()
            local connection, err = tcp:connect(conn_host, conn_port)
            if (err ~= nil) then
                print("dump of error newest .. " .. dump(err))
                print("Connection error")
                return
            end
            tcp:close()
            local p = player:get_pos()
            local d = player:get_look_dir()
            local pos = {
                x = math.floor(math.random(p.x, p.x + d.x * 10)),
                y = math.floor(math.random(p.y + 5, p.y + 5 + d.y * 10)),
                z = math.floor(math.random(p.z, p.z + d.z * 10))
            }
            local size = math.random(3, 7)
            create_platform(pos, size)
            spawn_instance(pos, size, host_info)
        end
    end)
