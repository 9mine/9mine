class 'stat'

function stat:stat(stat)
    self.stat = stat
end

function stat:get_name()
    return self.stat.name
end

function stat:get_path()
    return self.path
end

function stat:set_addr(addr)
    self.addr = addr
end

function stat:set_path(path)
    self.path = path == "/" and path .. self.stat.name or path .. "/" .. self.stat.name
end

function stat:get_addrpath()
    return self.addr .. self.path
end

function stat:get_qid()
    return self.stat.qid.path_hex
end

function stat:set_pos(pos)
    self.pos = table.copy(pos)
end

function stat:get_pos()
    return table.copy(self.pos)
end

function stat:set_stat(stat)
    self.stat = stat
end

function stat:set_platform_string(platform_string)
    self.platform_string = platform_string
end

function stat:get_platform_string()
    return self.platform_string
end

function stat:filter(stat_entity)
    local texture = "core_file.png"
    if self.stat.qid.type == 128 then
        texture = "core_dir.png"
    end
    local lua_entity = stat_entity:get_luaentity()
    lua_entity.stat = self.stat
    lua_entity.qid = self:get_qid()
    lua_entity.path = self:get_path()
    lua_entity.addrpath = self:get_addrpath()
    lua_entity.platform_string = self:get_platform_string()
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

