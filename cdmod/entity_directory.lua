-- register directory entity blueprint
minetest.register_entity("cdmod:directory", {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "sprite",
        collide_with_objects = true,
        textures = {"cdmod_folder.png"},
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
        is_visible = true,
        makes_footstep_sound = false,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true
    },
    -- path of the folder, set at time of adding
    path = "",
    size = 0,
    -- when hit with appropriate tool, create new platform for this directory
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities,
                        dir)
        print(self.path)
        if tool_capabilities.damage_groups.enter == 1 then
            local pos = puncher:get_pos()
            -- find glass in radius of 6
            local node_pos = minetest.find_node_near(pos, 6, {"cdmod:platform"})
            local node = minetest.get_meta(
                             {x = node_pos.x, y = node_pos.y, z = node_pos.z})
            local corner = node:get_string("corner")
            local corner_pos = minetest.deserialize(corner)

            local corner_node = minetest.get_meta(
                                    {
                    x = corner_pos.x,
                    y = corner_pos.y,
                    z = corner_pos.z
                })

            local cs = corner_node:get_string("new_center")
            print("dumping cs")
            print(dump(cs))
            local c = minetest.deserialize(cs)
            print("dumping c")
            print(dump(c))
            local cp = {x = c.x, y = c.y, z = c.z}
            local size = corner_pos.s
            local orientation = corner_pos.o

            local host_info_string = corner_node:get_string("host")
            local host_info = minetest.deserialize(host_info_string)

            local tcp = socket:tcp()
            local connection, err = tcp:connect(host_info["host"],
                                                host_info["port"])
            if (err ~= nil) then
                print("dump of error newest .. " .. dump(err))
                error("Connection error")
            end
            local conn = np.attach(tcp, "dievri", "")
            local content = read_directory(conn, self.path)

            local f = conn:newfid()
            if pcall(np.walk, conn, conn.rootfid, f, self.path .. "/.viz") ==
                false then
                print("no vertical file")
            else
                conn:open(f, 2)
                local statistics = conn:stat(f)
                local buf = conn:read(f, 0, statistics.length - 1)
                if tostring(buf) == "vertical" then
                    orientation = "v"
                end
                conn:clunk(f)
            end

            tcp:close()
            local size = 1
            if content ~= nil then size = table.getn(content) end

            local level = node_pos.y
            local platform_size = math.ceil(math.sqrt((size / 15) * 100))
            if platform_size < 3 then platform_size = 3 end

            local posx = math.random(-20, 20)
            local posz = math.random(-20, 20)
            local new_level = level + math.random(10, 20)
            local result = create_platform(posx, new_level, posz, platform_size,
                                           orientation, content, host_info, cp)

            puncher:set_pos({
                x = result.x + 1,
                y = result.y + 1,
                z = result.z + 1
            })

        end
    end,

    get_staticdata = function(self)
        local attributes = self.object:get_nametag_attributes()
        local data = {attr = attributes, path = self.path, size = self.size}
        return minetest.serialize(data)
    end,

    on_activate = function(self, staticdata, dtime_s)
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self.object:set_nametag_attributes(data.attr)
            self.path = data.path
            self.size = data.size
        end
    end
})

