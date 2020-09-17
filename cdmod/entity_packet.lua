minetest.register_entity("cdmod:packet", {
    initial_properties = {
        physical = false,
        pointable = true,
        visual = "cube",
        collide_with_objects = false,
        textures = {
            "cdmod_packet.png", "cdmod_packet.png", "cdmod_packet.png",
            "cdmod_packet.png", "cdmod_packet.png", "cdmod_packet.png"
        },
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
        is_visible = true,
        makes_footstep_sound = false,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true
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

minetest.register_node("cdmod:host", {
    drawtype = "glasslike",
    visual_scale = 1.0,
    tiles = {
        "cdmod_router.png", "cdmod_router.png", "cdmod_router.png",
        "cdmod_router.png", "cdmod_router.png", "cdmod_router.png"
    },
    use_texture_alpha = false,
    sunlight_propagates = false,
    walkable = true,
    pointable = true,
    diggable = true,
    node_box = {type = "regular"}
})
