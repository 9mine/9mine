class 'directory_entry'

-- object which encapsulates readdir entry
function directory_entry:directory_entry(stat)
    -- stat record from readdir
    self.stat = table.copy(stat)
    -- connection string, in form of prot!host!port
    self.addr = nil
    -- full path, starting with /, including entry name
    self.path = nil
    -- position of corresponding entity in for of {x, y, z}
    self.pos = nil
    -- platform path in for of /parent/platform/path
    self.platform_path = nil
    -- address and path of parent directory in for of prot!host!port/path
    self.platform_string = nil
    -- address and path of entry itself in form of prot!host!port/path/file.name
    self.entry_string = nil
    -- reference to the node, which holds reference to the current entry (self)
    self.node = nil
end

-- Getters
function directory_entry:get_stat() return self.stat end
function directory_entry:get_addr() return self.addr end
function directory_entry:get_path() return self.path end
function directory_entry:get_pos() return table.copy(self.pos) end
function directory_entry:get_platform_path() return self.platform_path end
function directory_entry:get_platform_string() return self.platform_string end
function directory_entry:get_entry_string() return self.entry_string end
function directory_entry:get_graph_entry_string() return self.entry_string .. self.stat.qid.path_hex end

-- Additional getters
-- return qid as hex string
function directory_entry:get_qid() return self.stat.qid.path_hex end

-- Setters
function directory_entry:set_stat(stat)
    self.stat = table.copy(stat)
    return self
end
function directory_entry:set_addr(addr)
    self.addr = addr
    return self
end
function directory_entry:set_pos(pos)
    self.pos = table.copy(pos)
    return self
end
function directory_entry:set_path(platform_path)
    self.path = platform_path == "/" and platform_path .. self.stat.name or platform_path .. "/"
                    .. self.stat.name
    return self
end
function directory_entry:set_platform_path(platform_path)
    self.platform_path = platform_path
    return self
end
function directory_entry:set_platform_string(platform_string)
    self.platform_string = platform_string
    return self
end
function directory_entry:set_entry_string()
    self.entry_string = self.addr .. self.path
    return self
end

-- methods
function directory_entry:filter(stat_entity, init_path, player_name)
    stat_entity:set_properties({
        nametag = self.stat.name,
        textures = {self.stat.qid.type == 128 and "core_dir.png" or "core_file.png"}
    })
    register.call_texture_handlers(self, stat_entity, init_path)
    local lua_entity = stat_entity:get_luaentity()
    lua_entity.player_name = player_name
    lua_entity.entry_string = self:get_entry_string()
    if minetest.get_node(self.pos).name == "core:platform" then
        stat_entity:set_acceleration({x = 0, y = -9.81, z = 0})
        minetest.after(math.random(1, 3), function()
            local pos = self:get_pos()
            pos.y = pos.y + 1
            stat_entity:set_acceleration({x = 0, y = 0, z = 0})
            stat_entity:set_pos(pos)
        end)
    else
        minetest.after(math.random(1, 3), function()
            if minetest.get_node(self.pos).name == "core:platform" then
                stat_entity:set_acceleration({x = 0, y = -9.81, z = 0})
            end
            minetest.after(math.random(1, 3), function()
                local pos = self:get_pos()
                pos.y = pos.y + 1
                stat_entity:set_acceleration({x = 0, y = 0, z = 0})
                stat_entity:set_pos(pos)
            end)
        end)
    end
    return self
end

function directory_entry:delete_node()
    if not self.node.object then
        self.node:delete()
        self.node = nil
    end
    return self
end

-- return new copy of current directory_entry
function directory_entry:copy()
    local new_directory_entry = directory_entry(self.stat)
    new_directory_entry.stat = self.stat
    new_directory_entry.addr = self.addr
    new_directory_entry.path = self.path
    new_directory_entry.pos = self.pos
    new_directory_entry.platform_path = self.platform_path
    new_directory_entry.platform_string = self.platform_string
    new_directory_entry.entry_string = self.entry_string
    new_directory_entry.node = self.node
    return new_directory_entry
end
