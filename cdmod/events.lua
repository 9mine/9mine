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
                port = conn_port,
                path = "/cmd"
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

        if formname == "cdmod:write" then
            if (fields["cmd"] == nil) then end
            local cmd = fields["cmd"]
            local host = fields["host"]
            local port = fields["port"]
            local path = fields["path"]
            print(cmd .. " " .. host .. " " .. port .. " " .. path)

            local tcp = socket:tcp()
            local connection, err = tcp:connect(host, port)
            if (err ~= nil) then
                print("dump of error newest .. " .. dump(err))
                print("Connection error")
                return
            end

            local conn = np.attach(tcp, "dievri", "")

            local g = conn:newfid(), conn:newfid()

            conn:walk(conn.rootfid, g, "/cmd")
            conn:open(g, 1)  

            local ftext = cmd
            local buf = data.new(ftext)

            local n = conn:write(g, 0, buf)
            if n ~= #buf then
                error(
                    "test: expected to write " .. #buf .. " bytes but wrote " ..
                        n)
            end

            conn:clunk(g)

            tcp:close()
            local host_info = {
                type = "tcp",
                host = host,
                port = port,
                path = "/cmd"
            }

            traceroute(host_info, player)

        end

    end)
