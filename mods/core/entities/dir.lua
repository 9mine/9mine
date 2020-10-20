-- register directory entity blueprint
minetest.register_entity("control9p:dir", {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "sprite",
        collide_with_objects = true,
        textures = {"control9p_dir.png"},
        is_visible = true,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true
    },
    -- path of the folder, set at time of adding
    path = "",
    addr = "",
    -- when hit with appropriate tool, create new platform for this directory
    on_punch = function(self, player, dtime, tool, dir)
        if tool.damage_groups.enter == 1 then
            list_directory(self.addr, self.path, player)
        end

        if tool.damage_groups.stats == 1 then
            -- show_stats(puncher, self.path)
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
