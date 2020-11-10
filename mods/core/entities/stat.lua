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
    texture = "",
    pos = "",
    stat = "",
    qid = "",
    addr = "",
    path = "",
    entry_string = "",
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
        CopyTool.copy(self, puncher)
    end
end

function StatEntity:get_staticdata()
    local attributes = self.object:get_nametag_attributes()
    local data = {
        texture = self.texture,
        pos = self.pos,
        stat = self.stat,
        qid = self.qid,
        addr = self.addr,
        path = self.path,
        entry_string = self.entry_string,
        platform_string = self.platform_string,
        attr = attributes
    }
    return minetest.serialize(data)
end

function StatEntity:on_activate(staticdata, dtime_s)
    if staticdata ~= "" and staticdata ~= nil then
        local data = minetest.deserialize(staticdata) or {}
        self.object:set_nametag_attributes(data.attr)
        self.pos = data.pos
        self.stat = data.stat
        self.qid = data.qid
        self.addr = data.addr
        self.path = data.path
        self.entry_string = data.entry_string
        self.platform_string = data.platform_string
        self.object:set_properties({
            textures = {data.texture}
        })
    end
end

minetest.register_entity("core:stat", StatEntity)
