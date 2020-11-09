local StatEntity = {
    initial_properties = {
        physical = true,
        pointable = true,
        visual = "sprite",
        collide_with_objects = true,
        textures = {"core_file.png"},
        is_visible = true,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true
    },
    qid = "",
    addr = "",
    platform_string = ""
}

function StatEntity:on_punch(puncher, dtime, tool, dir)
    local player_name = puncher:get_player_name()
    minetest.chat_send_all(self.qid)
    if tool.damage_groups.stats == 1 then
        -- show_stats(puncher, self.path)
    end
    if tool.damage_groups.enter == 1 then
        EnterTool.enter(self, puncher)
    end
    if tool.damage_groups.read == 1 then
        local content = file_read(self.addr, self.path, player_name)

        minetest.show_formspec(player_name, "core:file_content",
            table.concat({"formspec_version[3]", "size[13,13,false]", "textarea[0.5,0.5;12.0,12.0;;;",
                          minetest.formspec_escape(content), "]"}, ""))
        return
    end

    if tool.damage_groups.edit == 1 then
        local content = file_read(self.addr, self.path, player_name)
        local formspec = {"formspec_version[3]", "size[13,13,false]", "field[0,0;0,0;addr;;" .. self.addr .. "]",
                          "field[0,0;0,0;file_path;;" .. self.path .. "]", "textarea[0.5,0.5;12.0,10.6;content;;",
                          minetest.formspec_escape(content), "]", "button_exit[10,11.6;2.5,0.9;edit;edit]"}
        local form = table.concat(formspec, "")

        minetest.show_formspec(player_name, "core:edit", form)
        return
    end
    if tool.damage_groups.write == 1 then
        local player_name = puncher:get_player_name()
        local formspec = {"formspec_version[3]", "size[13,13,false]", "field[0,0;0,0;addr;;" .. self.addr .. "]",
                          "field[0,0;0,0;file_path;;" .. self.path .. "]", "textarea[0.5,0.5;12.0,10.6;content;;]",
                          "button_exit[10,11.6;2.5,0.9;write;write]"}
        local form = table.concat(formspec, "")

        minetest.show_formspec(player_name, "core:write", form)
        return
    end
    if tool.damage_groups.copy == 1 then
        local item = ItemStack("core:file_node")
        local item_meta = item:get_meta()
        item_meta:set_string("name", self.object:get_nametag_attributes().text)
        item_meta:set_string("addr", self.addr)
        item_meta:set_string("path", self.path)
        item_meta:set_string("description", self.addr .. ":" .. self.path)
        puncher:get_inventory():add_item("main", item)
    end
end

function StatEntity:get_staticdata()
    local attributes = self.object:get_nametag_attributes()
    local data = {
        attr = attributes,
        path = self.path,
        addr = self.addr
    }
    return minetest.serialize(data)
end

function StatEntity:on_activate(staticdata, dtime_s)
    if staticdata ~= "" and staticdata ~= nil then
        local data = minetest.deserialize(staticdata) or {}
        self.object:set_nametag_attributes(data.attr)
        self.path = data.path
        self.addr = data.addr
    end
end

minetest.register_entity("core:stat", StatEntity)
