class 'platform'

function platform:platform(conn, path, cmdchan)
    local refresh_time = tonumber(os.getenv("REFRESH_TIME") ~= "" and os.getenv("REFRESH_TIME") or
                                      core_conf:get("refresh_time"))
    self.conn = conn
    self.cmdchan = cmdchan
    self.addr = conn.addr
    self.path = path
    self.platform_string = conn.addr .. self.path
    self.directory_entries = {}
    self.properties = {
        refresh_time = refresh_time
    }
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

function platform:compute_size(content)
    local dir_size = math.ceil(math.sqrt((#content / 15) * 100))
    return dir_size < 3 and 3 or dir_size
end

function platform:draw(root_point, size)
    local slots = {}
    local p1 = root_point
    local p2 = {
        x = p1.x + size,
        y = p1.y,
        z = p1.z + size
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
    local directory_entry = directory_entry(stat)
    local slot = table.copy(self:get_slot())
    directory_entry:set_pos(slot)
    directory_entry:set_addr(self.conn.addr)
    directory_entry:set_path(self.path)
    directory_entry:set_entry_string()
    directory_entry:set_platform_string(self.platform_string)
    slot.y = slot.y + 7 + math.random(5)
    local stat_entity = minetest.add_entity(slot, "core:stat")
    directory_entry:filter(stat_entity)
    return directory_entry
end

function platform:get_entity_by_qid(qid)
    local old_pos = self.directory_entries[qid].pos
    local pos = table.copy(old_pos)
    pos.y = pos.y + 1
    return minetest.get_objects_inside_radius(pos, 0.5)[1], old_pos
end

function platform:remove_entity(qid)
    local stat_entity, pos = self:get_entity(qid)
    if stat_entity then
        stat_entity:set_acceleration({
            x = 0,
            y = 9,
            z = 0
        })
        table.insert(self.slots, pos)
        self.directory_entries[qid] = nil
        minetest.after(2, function(stat_entity)
            stat_entity:remove()
        end, stat_entity)
    else
        minetest.chat_send_all("Removing stat entity with qid " .. qid .. " failed")
    end
end

function platform:spawn_content(content)
    for _, stat in pairs(content) do
        self.directory_entries[stat.qid.path_hex] = self:spawn_stat(stat)
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
    local content = self:readdir()
    local size = self:compute_size(content)
    self:draw(root_point, size)
    self:spawn_content(self:readdir())
    self:update()
end
function platform:spawn_path_step(paths, player)
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

function platform:enlarge()
    local root = self.root_point
    local slots = self.slots
    local old_size = self.size
    local size = old_size * 2
    local size_diff = (size - old_size)
    size = size_diff % 2 == 1 and size - 1 or size

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
    minetest.show_formspec(player:get_player_name(), "platform:properties",
        table.concat({"formspec_version[3]", "size[10,6,false]", "label[4,0.5;Platform settings]",
                      "field[0.5,1;9,0.7;refresh_time;Refresh Frequency;" .. self.properties.refresh_time .. "]",
                      "button_exit[7,4.8;2.5,0.7;save;save]",
                      "field[0,0;0,0;platform_string;;" .. self.platform_string .. "]"}, ""))
end

function platform:update()
    local refresh_time = self:get_refresh_time()
    if refresh_time ~= 0 then
        local stats = self.directory_entries
        local new_content = common.qid_as_key(self:readdir())
        for qid, st in pairs(new_content) do
            if not stats[qid] then
                self:spawn_stat(st)
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
