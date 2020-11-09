class 'platform'

function platform:platform(conn, path, cmdchan, parent_node)
    local refresh_time = tonumber(os.getenv("REFRESH_TIME") ~= "" and os.getenv("REFRESH_TIME") or
                                      core_conf:get("refresh_time"))
    self.conn = conn
    self.cmdchan = cmdchan
    self.path = path
    self.connection_string = conn.addr .. self.path
    self.properties = {
        refresh_time = refresh_time
    }
    self.stats = {}
    self.parent_node = parent_node
end

function platform:readdir()
    local result, content = pcall(readdir, self.conn.attachment, self.path == "/" and "../" or self.path)
    if not result then
        if self.conn.attachment:is_alive() then
            minetest.chat_send_all("Connection is alive, but error reading content of directory: " .. content)
            return
        else
            if self.conn.attachment:reattach() then
                result, content = pcall(readdir, self.conn.attachment, self.path == "/" and "../" or self.path)
                if result then
                    content = content or {}
                end
            end
        end
    else
        self.content = content or {}
    end
    return content
end

function platform:set_size(size)
    if size then
        self.size = size
    else
        local dir_size = math.ceil(math.sqrt((#self.content / 15) * 100))
        self.size = dir_size < 3 and 3 or dir_size
    end
end

function platform:draw(root_point)
    local slots = {}
    local p1 = root_point
    local p2 = {
        x = p1.x + self.size,
        y = p1.y,
        z = p1.z + self.size
    }
    for z = p1.z, p2.z do
        for y = p1.y, p2.y do
            for x = p1.x, p2.x do
                local p = {
                    x = x,
                    y = y,
                    z = z
                }
                minetest.add_node(p, {
                    name = "core:platform"
                })
                local node = minetest.get_meta(p)
                node:set_string("connection_string", self.connection_string)
                table.insert(slots, p)
            end
        end
    end
    table.shuffle(slots)
    self.slots = slots
    self.root_point = root_point
end

function platform:get_root_point()
    return table.copy(self.root_point)
end

function platform:spawn_stat(stat)
    local slot = self:get_slot()
    local pos = table.copy(slot)
    stat:set_pos(pos)
    stat:set_connection_string(self.connection_string)
    stat:set_addr(self.conn.addr)
    stat:set_path(self.path)
    pos.y = pos.y + 7 + math.random(5)
    local stat_entity = minetest.add_entity(pos, "core:stat")
    local qid = stat:get_qid()
    self.stats[qid] = stat
    stat:filter(stat_entity)
end

function platform:get_stat_entity(qid)
    local pos = table.copy(self.stats[qid].pos)
    pos.y = pos.y + 1
    return minetest.get_objects_inside_radius(pos, 0.5)[1], pos
end

function platform:remove_stat(qid)
    local stat_entity, pos = self:get_stat_entity(qid)
    if stat_entity then
        stat_entity:set_acceleration({
            x = 0,
            y = 9,
            z = 0
        })
        minetest.after(2, function(self, e, pos, qid)
            table.insert(self.slots, pos)
            self.stats[qid] = nil
            e:remove()
        end, self, stat_entity, pos, qid)
    else
        minetest.chat_send_all("Removing stat entity with qid " .. qid .. " failed")
    end

end

function platform:spawn_content()
    for _, stat_value in pairs(self.content) do
        local stat = stat(stat_value)
        self:spawn_stat(stat)
    end
end

function platform:get_slot()
    local index, slot = next(self.slots)
    if not slot then
        platform:enlarge()
    end
    index, slot = next(self.slots)
    table.remove(self.slots, index)
    return slot
end

function platform:next_pos()
    local pos = table.copy(self.root_point)
    pos.y = pos.y + math.random(7, 12)
    pos.x = pos.x + math.random(30) - 15
    pos.z = pos.z + math.random(30) - 15
    return pos
end

function platform:spawn(root_point, size)
    self:readdir()
    self:set_size(size)
    self:draw(root_point)
    self:spawn_content()
end

function platform:spawn_child(path)
    local child_platform = platform(self.conn, path, self.cmdchan)
    local pos = self:next_pos()
    child_platform:spawn(pos)
    child_platform:set_node(platforms:add(child_platform, self))
    return child_platform
end

function platform:enlarge(new_size)
    local root = self.root_point
    local slots = self.slots
    local old_size = self.size
    local size = new_size or old_size * 2

    local size_diff = (size - old_size)
    local size = size_diff % 2 == 1 and size - 1 or size

    local p1 = {
        x = root.x - (size - old_size) / 2,
        y = root.y,
        z = root.z - (size - old_size) / 2
    }

    local p2 = {
        x = p1.x + size,
        y = p1.y,
        z = p1.z + size
    }
    for z = p1.z, p2.z do
        for y = p1.y, p2.y do
            for x = p1.x, p2.x do
                if ((x >= root.x and x <= root.x + old_size) and (z >= root.z and z <= root.z + old_size)) then
                else
                    local p = {
                        x = x,
                        y = y,
                        z = z
                    }
                    minetest.add_node(p, {
                        name = "core:platform"
                    })
                    local node = minetest.get_meta(p)
                    node:set_string("connection_string", self.connection_string)
                    table.insert(slots, p)
                end
            end
        end
    end
    self.size = size
    self.root_point = p1
    table.shuffle(slots)
end

function platform:set_node(node)
    self.node = node
end

function platform:get_node()
    return self.node
end
