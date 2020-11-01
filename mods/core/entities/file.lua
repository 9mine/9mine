minetest.register_entity("core:file", {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "sprite",
        collide_with_objects = true,
        textures = {"core_file.png"},
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
                local player_name = puncher:get_player_name()
                local content = file_read(self.addr, self.path, player_name)
        
                minetest.show_formspec(player_name, "core:file_content",
                                       table.concat(
                                           {
                        "formspec_version[3]", "size[13,13,false]",
                        "textarea[0.5,0.5;12.0,12.0;;;",
                        minetest.formspec_escape(content), "]"
                    }, ""))
        end

        if tool.damage_groups.edit == 1 then
            local player_name = puncher:get_player_name()
            local content = file_read(self.addr, self.path, player_name)
            local formspec = {
                "formspec_version[3]", "size[13,13,false]",
                "field[0,0;0,0;addr;;" .. self.addr .. "]",
                "field[0,0;0,0;file_path;;" .. self.path .. "]",
                "textarea[0.5,0.5;12.0,10.6;content;;", minetest.formspec_escape(content), "]",
                "button_exit[10,11.6;2.5,0.9;edit;edit]"
            }
            local form = table.concat(formspec, "")

            minetest.show_formspec(puncher:get_player_name(),
                                   "core:edit", form)
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
