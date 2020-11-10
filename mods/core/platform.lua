class 'platform'

function platform:platform(conn, path, cmdchan, parent_node)
    local refresh_time = tonumber(os.getenv("REFRESH_TIME") ~= "" and os.getenv("REFRESH_TIME") or
                                      core_conf:get("refresh_time"))
    self.conn = conn
    self.cmdchan = cmdchan
    self.path = path
    self.platform_string = self.conn.addr .. self.path
    self.properties = {
        refresh_time = refresh_time
    }
    self.stats = {}
    self.parent_node = parent_node
end

function platform:readdir()
    local result, content = pcall(readdir, self.conn.attachment, self.path == "/" and "../" or self.path)
    if not result then
        if self.conn.attachment and self.conn.attachment:is_alive() then
            minetest.chat_send_all("Connection is alive, but error reading content of directory: " .. content)
            return
        else
            if self.conn.attachment and self.conn.attachment:reattach() then
                result, content = pcall(readdir, self.conn.attachment, self.path == "/" and "../" or self.path)
                if result then
                    content = content or {}
                end
            end
        end
    else
        content = content or {}
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
                node:set_string("platform_string", self.platform_string)
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
    stat:set_platform_string(self.platform_string)
    stat:set_addr(self.conn.addr)
    stat:set_path(self.path)
    pos.y = pos.y + 7 + math.random(5)
    local stat_entity = minetest.add_entity(pos, "core:stat")
    self:set_stat(stat)
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
        table.insert(self.slots, pos)
        self:delete_stat(qid)
        minetest.after(2, function(self, e, pos, qid)
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
    self:set_content(self:readdir())
    self:set_size(size)
    self:draw(root_point)
    self:spawn_content()
    self:update()
end
function platform:spawn_path_step(paths, player)
    minetest.chat_send_all(dump(paths))
    local next = table.remove(paths)
    if not next then
        return
    end
    if not platforms:get_platform(self.conn.addr .. next) then
        local child_platform = self:spawn_child(next)
        common.goto_platform(player, child_platform:get_root_point())
        minetest.after(1.5, platform.spawn_path_step, child_platform, paths, player)
    else
        local child_platform = platforms:get_platform(self.conn.addr .. next)
        common.goto_platform(player, child_platform:get_root_point())
        minetest.after(0.5, platform.spawn_path_step, child_platform, paths, player)
    end
end

function platform:spawn_path(path, player)
    local paths = common.path_to_table(path)
    return self:spawn_path_step(paths, player)

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
                    node:set_string("platform_string", self.platform_string)
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

function platform:get_content()
    return self.content
end

function platform:set_content(content)
    self.content = content
end

function platform:get_stats()
    return self.stats
end

function platform:set_stats(stats)
    self.stats = stats
end

function platform:get_stat(qid)
    return self.stats[qid]
end

function platform:set_stat(stat)
    self.stats[stat:get_qid()] = stat
end

function platform:delete_stat(qid)
    self.stats[qid] = nil
end

function platform:get_refresh_time()
    return self.properties.refresh_time
end

function platform:set_refresh_time(refresh_time)
    self.properties.refresh_time = refresh_time
end

function platform:get_cmdchan()
    return self.cmdchan
end

function platform:get_path()
    return self.path
end

function platform:get_addr()
    return self.conn.addr
end

function platform:get_attachment()
    return self.conn.attachment
end
function platform:show_properties(player)
    local refresh_time = self:get_refresh_time()

    minetest.show_formspec(player:get_player_name(), "platform:properties",
        table.concat({"formspec_version[3]", "size[10,6,false]", "label[4,0.5;Platform settings]",
                      "field[0.5,1;9,0.7;refresh_time;Refresh Frequency;" .. refresh_time .. "]",
                      "button_exit[7,4.8;2.5,0.7;save;save]",
                      "field[0,0;0,0;platform_string;;" .. self.platform_string .. "]"}, ""))
end

function platform:update()
    local refresh_time = self:get_refresh_time()
    if refresh_time ~= 0 then
        local stats = self:get_stats()
        local new_content = common.qid_as_key(self:readdir())
        for qid, st in pairs(new_content) do
            if not stats[qid] then
                self:spawn_stat(stat(st))
            end
        end

        for qid in pairs(stats) do
            if not new_content[qid] then
                self:remove_stat(qid)
            end
        end
    end

    minetest.after(refresh_time == 0 and 1 or refresh_time, platform.update, self)
end
