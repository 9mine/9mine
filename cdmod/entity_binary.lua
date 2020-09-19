minetest.register_entity("cdmod:binary", {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "sprite",
        textures = {"cdmod_binary.png"},
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
        is_visible = true,
        makes_footstep_sound = false,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true
    },
    host = nil,
    port = nil,
    path = nil,
    color = nil,

    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities,
                        dir)
        if tool_capabilities.damage_groups.trace == 1 then
            local host_info = {
                type = "tcp",
                host = self.host,
                port = self.port,
                path = self.path,
                color = self.color
            }
            print("host_info dump in entity file: " .. dump(host_info))
            traceroute(host_info, puncher)
        end

        if tool_capabilities.damage_groups.write == 1 then
            local player_name = puncher:get_player_name()
            local host = self.host
            local port = self.port
            local path = self.path
            local formspec = {
                "formspec_version[3]", "size[10,3,false]",
                "field[0.0,0.0;0,0;host;enter host;" .. host .. "]",
                "field[0.0,0.0;0,0;port;enter port;" .. port .. "]",
                "field[0.0,0.0;0,0;path;enter path;" .. path .. "]",
                "field[0.5,0.5;9,1;cmd;Enter command string;]",
                "button_exit[7,1.8;2.5,0.9;write;write]"
            }
            local form = table.concat(formspec, "")
            minetest.show_formspec(player_name, "cdmod:write", form)

        end

    end,

    get_staticdata = function(self)
        local attributes = self.object:get_nametag_attributes()
        local data = {
            attr = attributes,
            path = self.path,
            host = self.host,
            port = self.port,
            color = self.color
        }
        return minetest.serialize(data)
    end,

    on_activate = function(self, staticdata, dtime_s)
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self.object:set_nametag_attributes(data.attr)
            self.path = data.path
            self.port = data.port
            self.host = data.host
            self.color = data.color
        end
    end
})
