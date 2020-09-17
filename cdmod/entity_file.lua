-- register files entity blueprint
minetest.register_entity("cdmod:file", {
    -- default values 
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "sprite",
        textures = {"cdmod_file.png"},
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
        is_visible = true,
        makes_footstep_sound = false,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true
    },
    -- when file is hitten by appropriate tool, read content of the file
    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities,
                        dir)
        -- if tools is appropriate
        if tool_capabilities.damage_groups.read == 1 then
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

            local host_info_string = corner_node:get_string("host")
            local host_info = minetest.deserialize(host_info_string)

            local player = puncher:get_player_name()
            local tcp = socket:tcp()
            local connection, err = tcp:connect(host_info["host"],
                                                host_info["port"])
            if (err ~= nil) then
                print("dump of error newest .. " .. dump(err))
                error("Connection error")
            end
            local conn = np.attach(tcp, "dievri", "")
            local f = conn:newfid()
            print("PATH IS ... " .. self.path)
            np:walk(conn.rootfid, f, self.path)
            conn:open(f, 0)
            local statistics = conn:stat(f)
            local buf = conn:read(f, 0, statistics.length - 1)
            local content = tostring(buf)
            conn:clunk(f)
            tcp:close()

            -- define form to be shown
            local formspec = {
                "formspec_version[3]", "size[13,13,false]",
                "textarea[0.5,0.5;12.0,12.0;;;",
                minetest.formspec_escape(content), "]"
            }
            local form = table.concat(formspec, "")

            -- show form to the player
            minetest.show_formspec(player, "cdmod:file_content", form)
        end
    end,

    -- make file entities fall in air
    on_activate = function(self, staticdata, dtime_s)
        self.object:set_acceleration({x = 0, y = -7, z = 0})
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self.object:set_nametag_attributes(data.attr)
        end
    end,

    get_staticdata = function(self)
        local attributes = self.object:get_nametag_attributes()
        local data = {attr = attributes}
        return minetest.serialize(data)
    end
})
