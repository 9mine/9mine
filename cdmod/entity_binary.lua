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

    on_punch = function(self, puncher, time_from_last_punch, tool_capabilities,
                        dir)
        if tool_capabilities.damage_groups.trace == 1 then
            local host_info = {
                type = "tcp",
                host = self.host,
                port = self.port,
                path = self.path
            }
            traceroute(host_info, puncher)
        end
    end,

    get_staticdata = function(self)
        local attributes = self.object:get_nametag_attributes()
        local data = {
            attr = attributes,
            path = self.path,
            host = self.host,
            port = self.port
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
        end
    end
})
