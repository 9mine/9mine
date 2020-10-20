minetest.register_entity("control9p:file", {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "sprite",
        collide_with_objects = true,
        textures = {"control9p_file.png"},
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
    addr = "",
    stat = "",
    on_punch = function(self, puncher, dtime, tool, dir)
        if tool.damage_groups.stats == 1 then
            -- show_stats(puncher, self.path)
        end

        if tool.damage_groups.read == 1 then
            -- local host_info = get_host_near(puncher)
            -- local content = read_file_content(host_info, self.path)
            -- local formspec = {
            --     "formspec_version[3]", "size[13,13,false]",
            --     "textarea[0.5,0.5;12.0,12.0;;;",
            --     minetest.formspec_escape(content), "]"
            -- }
            -- local form = table.concat(formspec, "")

            -- minetest.show_formspec(puncher:get_player_name(),
            --                        "directories:file_content", form)
        end

        if tool.damage_groups.write == 1 then
            local formspec = {
                "formspec_version[3]", "size[13,13,false]",
                "field[0,0;0,0;file_name;;" .. self.stat.name .. "]",
                "textarea[0.5,0.5;12.0,10.6;links;;]",
                "button_exit[10,11.6;2.5,0.9;write;write]"
            }
            local form = table.concat(formspec, "")

            minetest.show_formspec(puncher:get_player_name(),
                                   "control9p:write_file", form)
        end
    end,

    get_staticdata = function(self)
        local attributes = self.object:get_nametag_attributes()
        local data = {attr = attributes, path = self.path, addr = self.addr}
        return minetest.serialize(data)
    end,

    on_activate = function(self, staticdata, dtime_s)
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self.object:set_nametag_attributes(data.attr)
            self.path = data.path
            self.addr = data.addr
        end
    end
})
