class 'directory_entry'

-- object which encapsulates readdir entry
function directory_entry:directory_entry(stat)
    -- stat record from readdir 
    self.stat = stat
    -- attachment string, in form of prot!host!port
    self.addr = nil
    -- full path, starting with /, including entry name 
    self.path = nil
    -- position of corresponding entity in for of {x, y, z}
    self.pos = nil
    -- address and path of parent directory in for of prot!host!port/path
    self.platform_string = nil
    -- address and path of entry itself in form of prot!host!port/path/file.name
    self.entry_string = nil
end

-- Getters
function directory_entry:get_stat()
    return self.stat
end
function directory_entry:get_addr()
    return self.addr
end
function directory_entry:get_path()
    return self.path
end
function directory_entry:get_pos()
    return self.pos
end
function directory_entry:get_platform_string()
    return self.platform_string
end
function directory_entry:get_entry_string()
    return self.entry_string
end
function directory_entry:get_graph_entry_string()
    return self.entry_string .. self.stat.qid.path_hex
end

-- Additional getters
-- return qid as hex string
function directory_entry:get_qid()
    return self.stat.qid.path_hex
end

-- Setters
function directory_entry:set_stat(stat)
    self.stat = table.copy(stat)
end
function directory_entry:set_addr(addr)
    self.addr = addr
end
function directory_entry:set_pos(pos)
    self.pos = table.copy(pos)
end
function directory_entry:set_path(platform_path)
    self.path = platform_path == "/" and platform_path .. self.stat.name or platform_path .. "/" .. self.stat.name
end
function directory_entry:set_platform_string(platform_string)
    self.platform_string = platform_string
end
function directory_entry:set_entry_string()
    self.entry_string = self.addr .. self.path
end

-- methods
function directory_entry:filter(stat_entity)
    local texture = "core_file.png"
    if self.stat.qid.type == 128 then
        texture = "core_dir.png"
    end
    local lua_entity = stat_entity:get_luaentity()
    lua_entity.texture = texture
    lua_entity.pos = self:get_pos()
    lua_entity.stat = self:get_stat()
    lua_entity.qid = self:get_qid()
    lua_entity.addr = self:get_addr()
    lua_entity.path = self:get_path()
    lua_entity.entry_string = self:get_entry_string()
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

