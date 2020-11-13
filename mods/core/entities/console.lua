minetest.register_entity("core:console", {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "cube",
        collide_with_objects = true,
        textures = {"core_console.png", "core_console.png", "core_console.png", "core_console.png", "core_console.png",
                    "core_console.png"},
        is_visible = true,
        nametag_color = "black",
        static_save = true,
        shaded = true
    },
    path = "",
    addr = "",
    output = "",
    input = "",
    on_punch = function(self, player, dtime, tool, dir)
        local p = self.object:get_pos()
        local pos = minetest.serialize(p)
        local formspec = {"formspec_version[3]", "size[13,13,false]",
                          "textarea[0.5,0.5;12.0,10;;;" .. minetest.formspec_escape(self.output) .. "]",
                          "field[0.5,10.5;12,1;input;;\\; ]", "field_close_on_enter[input;false]",
                          "button[10,11.6;2.5,0.9;send;send]",
                          "field[13,13;0,0;entity_pos;;" .. minetest.formspec_escape(pos) .. "]"}
        local form = table.concat(formspec, "")

        minetest.show_formspec(player:get_player_name(), "core:console", form)

    end,

    get_staticdata = function(self)
        local attributes = self.object:get_nametag_attributes()
        local data = {
            attr = attributes,
            path = self.path,
            addr = self.addr,
            input = self.input,
            output = self.output
        }
        return minetest.serialize(data)
    end,

    on_activate = function(self, staticdata, dtime_s)
        if staticdata ~= "" and staticdata ~= nil then
            local data = minetest.deserialize(staticdata) or {}
            self.object:set_nametag_attributes(data.attr)
            self.path = data.path
            self.addr = data.addr
            self.input = data.input
            self.output = data.output

        end
    end
})
