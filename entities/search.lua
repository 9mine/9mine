minetest.register_entity("youtube:search", {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "sprite",
        collide_with_objects = true,
        textures = {"youtube_search.png"},
        is_visible = true,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true
    },

    search_string = "",

    on_punch = function(self, puncher, dtime, tool, dir)
        minetest.show_formspec(puncher:get_player_name(), "youtube:search",
                               table.concat(
                                   {
                "formspec_version[3]", "size[10,3,false]",
                "field[0.5,0.5;9,1;search_string;Search on YouTube;]",
                "button_exit[7,1.8;2.5,0.9;search;search]"
            }, ""))
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
