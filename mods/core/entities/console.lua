local ConsoleEntity = {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "cube",
        collide_with_objects = true,
        textures = {
            "core_console.png", "core_console.png", "core_console.png",
            "core_console.png", "core_console.png", "core_console.png"
        },
        is_visible = true,
        nametag_color = "black",
        static_save = true,
        shaded = true
    },
    path = "",
    addr = "",
    output = "",
    input = ""
}

function ConsoleEntity:on_punch(player, dtime, tool, dir)
    local p = self.object:get_pos()
    local pos = minetest.serialize(p)
    local request = self.user == "glenda" and "%" or "\\;"
    minetest.show_formspec(player:get_player_name(), "core:console",
                           table.concat({
        "formspec_version[3]", "size[13,13,false]",
        "textarea[0.5,0.5;12.0,10;;;" .. minetest.formspec_escape(self.output) ..
            "]", "field[0.5,10.5;12,1;input;;" .. request .. " ]",
        "field_close_on_enter[input;false]",
        "button[10,11.6;2.5,0.9;send;send]",
        "field[13,13;0,0;entity_pos;;" .. minetest.formspec_escape(pos) .. "]"
    }, ""))
end

function ConsoleEntity:get_staticdata()
    local attributes = self.object:get_nametag_attributes()
    local data = {
        attr = attributes,
        path = self.path,
        addr = self.addr,
        input = self.input,
        output = self.output
    }
    return minetest.serialize(data)
end

function ConsoleEntity:on_activate(staticdata, dtime_s)
    if staticdata ~= "" and staticdata ~= nil then
        local data = minetest.deserialize(staticdata) or {}
        self.object:set_nametag_attributes(data.attr)
        self.path = data.path
        self.addr = data.addr
        self.input = data.input
        self.output = data.output
    end
end

minetest.register_entity("core:console", ConsoleEntity)
