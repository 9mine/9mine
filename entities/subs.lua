minetest.register_entity("youtube:subs", {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "cube",
        collide_with_objects = true,
        textures = {
            "youtube_video.png", "youtube_video.png", "youtube_video.png",
            "youtube_video.png", "youtube_video.png", "youtube_video.png"
        },
        is_visible = true,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true,
        armor_groups = {immortal = 0},
        nametag_color = "black"
    },

    on_punch = function(self, puncher, dtime, tool, dir)
        local pn = puncher:get_player_name()
        local addr = plt_by_name(pn)
        local content = file_read(addr, self.path, pn)
        local formspec = {
            "formspec_version[3]", "size[13,13,false]",
            "textarea[0.5,0.5;12.0,12.0;;;", minetest.formspec_escape(content),
            "]"
        }
        local form = table.concat(formspec, "")

        minetest.show_formspec(pn, "youtube:subs_content", form)

    end,

    get_staticdata = function(self)
        local attributes = self.object:get_nametag_attributes()
        local data = {attr = attributes}
        return minetest.serialize(data)
    end,

    on_activate = function(self, staticdata, dtime_s)
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self.object:set_nametag_attributes(data.attr)
        end
    end
})
