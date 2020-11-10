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
    if tool.damage_groups.stats == 1 then
        -- show_stats(puncher, self.path)
    end
    if tool.damage_groups.enter == 1 then
        EnterTool.enter(self, puncher, player_name)
    end
    if tool.damage_groups.read == 1 then
        ReadTool.read(self, puncher, player_name)
    end

    if tool.damage_groups.edit == 1 then
        EditTool.edit(self, puncher, player_name)
    end
    if tool.damage_groups.write == 1 then
        WriteTool.write(self, player_name)
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
