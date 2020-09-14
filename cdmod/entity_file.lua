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
            local player = puncher:get_player_name()
            local file = io.open(self.path)
            if file == nil then return end
            local content = file:read("*all")

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
