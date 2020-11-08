class 'stat'

function stat:stat(stat)
    self.stat = stat
end

function stat:get_name()
    return self.stat.name
end

function stat:get_qid()
    return self.stat.qid.path_hex
end

function stat:set_pos(pos)
    self.pos = table.copy(pos)
end

function stat:filter(stat_entity)
    local texture = "core_file.png"
    if self.stat.qid.type == 128 then
        texture = "core_dir.png"
    end
    stat_entity:get_luaentity().stat = self.stat
    stat_entity:get_luaentity().qid = self:get_qid()
    stat_entity:set_properties({
        textures = {texture},
        nametag = self.stat.name
    })
    stat_entity:set_acceleration({
        x = 0,
        y = -9.81,
        z = 0
    })
end

