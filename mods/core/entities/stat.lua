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
    entry_string = ""
}

function StatEntity:on_punch(puncher, _, tool, _)
    local player_name = puncher:get_player_name()
    local player_graph = graphs:get_player_graph(player_name)
    local directory_entry = player_graph:get_entry(self.entry_string)
    if not directory_entry then
        minetest.chat_send_player(player_name, "No directory entry found")
        return
    end
    if tool.damage_groups.stat == 1 then StatTool.show_stat(self, puncher, player_name) end
    if tool.damage_groups.enter == 1 then EnterTool.enter(self, puncher, player_name) end
    if tool.damage_groups.read == 1 then ReadTool.read(self, puncher, player_name, player_graph) end
    if tool.damage_groups.edit == 1 then EditTool.edit(self, puncher, player_name) end
    if tool.damage_groups.write == 1 then WriteTool.write(self, player_name) end
    if tool.damage_groups.copy == 1 then CopyTool.copy(self, puncher) end
    if tool.damage_groups.remove == 1 then RemoveTool.remove(self, puncher) end
end

function StatEntity:get_staticdata()
    local attributes = self.object:get_nametag_attributes()
    local properties = self.object:get_properties()
    if not properties then
        print("error getting static data")
        return
    end
    local data = {
        player_name = self.player_name,
        visual = properties.visual,
        textures = properties.textures,
        entry_string = self.entry_string,
        attr = attributes,
        external_on_punch = self.external_on_punch
    }
    return minetest.serialize(data)
end

function StatEntity:on_activate(staticdata)
    if staticdata ~= "" and staticdata ~= nil then
        local data = minetest.deserialize(staticdata) or {}
        self.object:set_nametag_attributes(data.attr)
        self.entry_string = data.entry_string
        self.player_name = data.player_name
        self.object:set_properties({visual = data.visual, textures = data.textures})
        local player_graph = graphs:get_player_graph(self.player_name)
        if player_graph then
            local directory_entry = player_graph:get_entry(self.entry_string)
            if not directory_entry then
                self.object:remove()
                return
            end
            local pos = directory_entry:get_pos()
            pos.y = pos.y + 1
            self.object:set_pos(pos)
        end
        if data.external_on_punch ~= "" then
            self.on_punch = data.external_on_punch
            setfenv(self.on_punch, _G)
        end
    end

end

minetest.register_entity("core:stat", StatEntity)
