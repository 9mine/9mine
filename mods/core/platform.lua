class 'platform'
-- platform object. Represents directory content. Holds reference to connection information
function platform:platform(conn, path, cmdchan, parent_node)
    local refresh_time = tonumber(os.getenv("REFRESH_TIME") ~= "" and os.getenv("REFRESH_TIME") or
                                      core_conf:get("refresh_time"))
    self.conn = conn
    self.cmdchan = cmdchan
    self.addr = conn.addr
    self.path = path
    self.platform_string = conn.addr .. self.path
    self.directory_entries = {}
    self.properties = {
        -- flag indicating that platform update will be mabe by some other function 
        -- than platform:update()
        external_handler = false,
        -- period of time, on which readdir() occurs for current platform and if 
        -- new entries are there, they will be spawn and if some of present entities 
        -- are no more in new readdir() they will removed
        refresh_time = refresh_time
    }
    -- parent node in graph. During spawn edge made between current platform and parent platform
    -- or host node, if platform inself is root platform
    self.node = parent_node
    -- position if form of {x, y, z}, location of node core:platform, on top of which can be spawned
    -- new directory entry
    self.slots = nil
end

-- methods
-- reads content of directory using path, set during platform initialization
function platform:readdir()
    local result, content = pcall(readdir, self.conn.attachment, self.path == "/" and "../" or self.path)
    if not result then
        if self.conn:is_alive() then
            minetest.chat_send_all("Connection is alive, but error reading content of directory: " .. content)
            return
        else
            if self.conn:reattach() then
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

-- computes acceptable size for platform to hold content of directory freely
function platform:compute_size(content)
    local dir_size = math.ceil(math.sqrt((#content / 15) * 100))
    return dir_size < 3 and 3 or dir_size
end

-- sets platform nodes on area specified
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
    self.size = size
end

function platform:wipe_top()
    for qid, entry in pairs(self.directory_entries) do
        platforms:delete_entry_node(entry:get_entry_string())
        self:remove_entity(qid)
    end
end

function platform:wipe()
    self:wipe_top()
    platforms:delete_node(self.platform_string)
    local root_point = self.root_point
    local size = self.size
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
                    name = "air"
                })
            end
        end
    end
end

-- returns copy of platform root (corner) node position
function platform:get_root_point()
    if not self.root_point then
        minetest.chat_send_all("No root point found for platform.")
        return
    end
    return table.copy(self.root_point)
end

function platform:configure_entry(directory_entry)
    directory_entry:set_addr(self.addr)
    directory_entry:set_path(self.path)
    directory_entry:set_platform_path(self.path)
    directory_entry:set_entry_string()
    directory_entry:set_platform_string(self.platform_string)
end

-- takes stat record (from readdir) and spawn entity with given properties
function platform:spawn_stat(stat)
    local directory_entry = directory_entry(stat)
    local slot = table.copy(self:get_slot())

    directory_entry:set_pos(slot)
    self:configure_entry(directory_entry)
    slot.y = slot.y + 7 + math.random(5)
    local stat_entity = minetest.add_entity(slot, "core:stat")
    directory_entry:filter(stat_entity)
    return directory_entry
end

-- provided with qid, return referece for corresponding entity
function platform:get_entity_by_qid(qid)
    local old_pos = self.directory_entries[qid].pos
    local pos = table.copy(old_pos)
    pos.y = pos.y + 1
    return minetest.get_objects_inside_radius(pos, 0.5)[1], old_pos
end

function platform:get_entity_by_name(name)
    local entry_string
    if self.platform_string:match("/$") then
        entry_string = self.platform_string .. name
    else
        entry_string = self.platform_string .. "/" .. name
    end
    local directory_entry = platforms:get_entry(entry_string)
    local old_pos = directory_entry.pos
    local pos = table.copy(old_pos)
    pos.y = pos.y + 1
    return minetest.get_objects_inside_radius(pos, 0.5)[1], old_pos
end

function platform:get_entity_by_pos(old_pos)
    local pos = table.copy(old_pos)
    pos.y = pos.y + 1
    return minetest.get_objects_inside_radius(pos, 0.5)[1], old_pos
end

function platform:get_entry_by_name(name)
    local entry_string
    if self.platform_string:match("/$") then
        entry_string = self.platform_string .. name
    else
        entry_string = self.platform_string .. "/" .. name
    end
    local directory_entry = platforms:get_entry(entry_string)
    return directory_entry
end

-- provided with qid, removes corresponding entity
function platform:remove_entity(qid)
    local stat_entity, pos = self:get_entity_by_qid(qid)
    if stat_entity then
        stat_entity:set_acceleration({
            x = 0,
            y = 9,
            z = 0
        })
        table.insert(self.slots, pos)
        self.directory_entries[qid] = nil
        minetest.after(1.5, function(stat_entity)
            stat_entity:remove()
        end, stat_entity)
    else
        minetest.chat_send_all("Removing stat entity with qid " .. qid .. " failed")
    end
end

-- takes results of readdir and spawn each directory entry from it
function platform:spawn_content(content)
    for _, stat in pairs(content) do
        local directory_entry = self:spawn_stat(stat)
        self.directory_entries[stat.qid.path_hex] = directory_entry
        platforms:add_directory_entry(self, directory_entry)
    end
end

-- returns next free slot. If no free slots, than doubles platform
-- and returns free slots from there
function platform:get_slot()
    if common.table_length(self.slots) / (self.size ^ 2) < 0.50 then
        self:enlarge()
    end
    local index, slot = next(self.slots)
    table.remove(self.slots, index)
    return table.copy(slot)
end

-- calculates position for child directory
function platform:next_pos()
    local pos = table.copy(self.root_point)
    pos.y = pos.y + math.random(10, 16)
    pos.x = pos.x + math.random(60) - 15
    pos.z = pos.z + math.random(60) - 15
    return pos
end

-- read directory and spawn platform with directory content 
function platform:spawn(root_point)
    local content = self:readdir()
    if not content then
        return nil
    end
    local size = self:compute_size(content)
    self:draw(root_point, size)
    minetest.after(0.2, function(plt, content)
        platform.spawn_content(plt, content)
        platform.update(plt)
    end, self, content)
    -- self:spawn_content(content)
    -- self:update()
end

-- receives table with paths to spawn platform after platform
-- until there is path in paths 
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

-- convert path to a list of paths to be spawn 
-- one after another 
function platform:spawn_path(path, player)
    local paths = common.path_to_table(path)
    return self:spawn_path_step(paths, player)
end

-- spawn one one platform directory as a separate platform
function platform:spawn_child(path)
    local child_platform = platform(self.conn, path, self.cmdchan)
    child_platform.node = (platforms:add(child_platform, self))
    local pos = self:next_pos()
    child_platform:spawn(pos)
    return child_platform
end

-- double the size of the platform. This make available free slots 
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

-- when platform node punched, formspec show with table properties
-- :feresh_time - time between platform updates, in seconds
function platform:show_properties(player)
    minetest.show_formspec(player:get_player_name(), "platform:properties",
        table.concat({"formspec_version[3]", "size[10,6,false]", "label[4,0.5;Platform settings]",
                      "field[0.5,1;9,0.7;refresh_time;Refresh Frequency;" .. self.properties.refresh_time .. "]",
                      "field[0.5,2;9,0.7;external_handler;External Handler;" ..
            tostring(self.properties.external_handler) .. "]", "button_exit[7,4.8;2.5,0.7;save;save]",
                      "field[0,0;0,0;platform_string;;" .. self.platform_string .. "]"}, ""))
end

-- reads directory content and spawn new entities if needed
-- and deletes entities, that are not present in new directory content  
function platform:update()
    local refresh_time = self:get_refresh_time()
    if refresh_time ~= 0 and (not self.properties.external_handler) then
        local stats = self.directory_entries
        local new_content = common.qid_as_key(self:readdir())
        if not new_content then
            self:wipe()
            return
        end
        for qid, st in pairs(new_content) do
            if not stats[qid] then
                local directory_entry = self:spawn_stat(st)
                platforms:add_directory_entry(self, directory_entry)
                self.directory_entries[qid] = directory_entry

            end
        end
        for qid in pairs(stats) do
            if not new_content[qid] then
                local directory_entry_node = self.directory_entries[qid].node
                directory_entry_node:delete()
                self:remove_entity(qid)
            end
        end
    end
    minetest.after(refresh_time == 0 and 1 or refresh_time, platform.update, self)
end

function platform:delete_entry(entry)
    self.directory_entries[entry.stat.qid.path_hex] = nil
end

function platform:delete_entry_by_qid(qid)
    self.directory_entries[qid] = nil
end

function platform:add_entry(entry)
    self.directory_entries[entry.stat.qid.path_hex] = entry
end

function platform:inject_entry(entry)
    self:configure_entry(entry)
    self:add_entry(entry)
end

-- Getters

function platform:get_node()
    return self.node
end

function platform:get_refresh_time()
    return self.properties.refresh_time
end

function platform:get_attachment()
    return self.conn.attachment
end

function platform:get_cmdchan()
    return self.cmdchan
end

function platform:get_addr()
    return self.conn.addr
end

function platform:get_path()
    return self.path
end

-- Setters
function platform:set_node(node)
    self.node = node
end

function platform:set_refresh_time(refresh_time)
    self.properties.refresh_time = refresh_time
end

function platform:set_external_handler_flag(flag)
    self.properties.external_handler = flag
end

