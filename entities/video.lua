minetest.register_entity("youtube:video", {
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
