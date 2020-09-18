minetest.register_on_player_receive_fields(
    function(player, formname, fields)
        if formname == "cdmod:connect" then
            if (fields["conn_string"] == nil) then end
            local conn_string = fields["conn_string"]
            print(conn_string)
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
            local conn = np.attach(tcp, "dievri", "")
            local root_dir = read_directory(conn, ".")
            local size = table.getn(root_dir)
            local p = player:get_pos()
            tcp:close()
            local d = player:get_look_dir()
            create_platform(math.floor(math.random(p.x, p.x + d.x * 10)),
                            math.floor(math.random(p.y + 5, p.y + 5 + d.y * 10)),
                            math.floor(math.random(p.z, p.z + d.z * 10)), size,
                            "h", root_dir, host_info)
        end
    end)
