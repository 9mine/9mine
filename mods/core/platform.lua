class 'platform'
-- platform object. Represents directory content. Holds reference to connection information
function platform:platform(connection, path, cmdchan, parent_node)
    local refresh_time = tonumber(os.getenv("REFRESH_TIME") ~= "" and os.getenv("REFRESH_TIME") or
                                      core_conf:get("refresh_time"))
    self.connection = connection
    self.cmdchan = cmdchan
    self.addr = connection.addr
    self.path = path
    self.platform_string = connection.addr .. self.path
    self.directory_entries = {}
    self.properties = {
        -- name of the player, who have access to the platform
        player_name = "",
        -- flag indicating that platform update will be mabe by some other function 
        -- than platform:update()
        external_handler = true,
        -- period of time, on which readdir() occurs for current platform and if 
        -- new entries are there, they will be spawn and if some of present entities 
        -- are no more in new readdir() they will removed
        refresh_time = refresh_time,
        -- count of the spawn platforms of directories
        spawn_platforms = 0
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
    local result, content = pcall(readdir, self.connection.conn, self.path == "/" and "./" or self.path)
    if not result then
        if self.connection:is_alive() then
            minetest.chat_send_player(self:get_player(),
                "Connection is alive, but error reading content of directory: " .. content)
            return
        else
            if self.connection:reattach() then
                result, content = pcall(readdir, self.connection.conn, self.path == "/" and "../" or self.path)
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
    local sqrt = math.sqrt(#content)
    local dir_size = math.ceil(sqrt + math.sqrt(sqrt) + 3)
    return dir_size < 3 and 3 or dir_size
end

-- sets platform nodes on area specified
function platform:draw(root_point, size, color)
    local slots = {}
    local p1 = root_point
    local p2 = {
        x = p1.x + size,
        y = p1.y,
        z = p1.z + size
    }
    self.properties.area_id = area_store:insert_area(p1, p2, self.platform_string)
    local core_platform_node = minetest.get_content_id("core:platform")
    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(p1, p2)
    local data = vm:get_data()
    local param2 = vm:get_param2_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    for z = p1.z, p2.z do
        for y = p1.y, p2.y do
            for x = p1.x, p2.x do
                local vi = a:index(x, y, z)
                data[vi] = core_platform_node
                param2[vi] = color
                table.insert(slots, {
                    x = x,
                    y = y,
                    z = z
                })
            end
        end
    end
    vm:set_data(data)
    vm:set_param2_data(param2)
    vm:write_to_map(true)
    table.shuffle(slots)
    self.slots = slots
    self.root_point = root_point
    self.size = size
    self.properties.color = color
end

function platform:colorize(color)
    local slots = {}
    local p1 = self.root_point
    local p2 = {
        x = p1.x + self.size,
        y = p1.y,
        z = p1.z + self.size
    }
    local core_platform_node = minetest.get_content_id("core:platform")
    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(p1, p2)
    local param2 = vm:get_param2_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    for z = p1.z, p2.z do
        for y = p1.y, p2.y do
            for x = p1.x, p2.x do
                local p = {
                    x = x,
                    y = y,
                    z = z
                }
                local vi = a:index(x, y, z)
                param2[vi] = color
            end
        end
    end
    vm:set_param2_data(param2)
    vm:write_to_map(true)
    self.properties.color = color
end

function platform:wipe_top()
    local player_graph = graphs:get_player_graph(self:get_player())
    for qid, entry in pairs(self.directory_entries) do
        player_graph:delete_entry_node(entry:get_entry_string())
        self:remove_entity(qid)
    end
end

function platform:wipe()
    self:wipe_top()
    local player_graph = graphs:get_player_graph(self:get_player())
    player_graph:delete_node(self.platform_string)
    self:delete_nodes()
    area_store:remove_area(self.properties.area_id)
end

function platform:delete_nodes()
    local root_point = self.root_point
    local size = self.size
    local p1 = root_point
    local p2 = {
        x = p1.x + size,
        y = p1.y,
        z = p1.z + size
    }
    local air_node = minetest.get_content_id("air")
    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(p1, p2)
    local data = vm:get_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
    }
    for z = p1.z, p2.z do
        for y = p1.y, p2.y do
            for x = p1.x, p2.x do
                local vi = a:index(x, y, z)
                data[vi] = air_node
            end
        end
    end
    vm:set_data(data)
    vm:write_to_map(true)
end

-- returns copy of platform root (corner) node position
function platform:get_root_point()
    if not self.root_point then
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
    slot.y = slot.y + 7 + math.random(5, 12)
    local stat_entity = minetest.add_entity(slot, "core:stat")
    directory_entry:filter(stat_entity, nil, self:get_player())
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
    local player_graph = graphs.get_player_graph(self:get_player())
    local entry_string
    if self.platform_string:match("/$") then
        entry_string = self.platform_string .. name
    else
        entry_string = self.platform_string .. "/" .. name
    end
    local directory_entry = player_graph:get_entry(entry_string)
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
    local player_graph = graphs:get_player_graph(self:get_player())
    local entry_string
    if self.platform_string:match("/$") then
        entry_string = self.platform_string .. name
    else
        entry_string = self.platform_string .. "/" .. name
    end
    local directory_entry = player_graph:get_entry(entry_string)
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
        minetest.after(1.5, function()
            stat_entity:remove()
        end)
    else

        minetest.chat_send_player(self:get_player(), "Removing stat entity with qid " .. qid .. " failed")
    end
end

-- takes results of readdir and spawn each directory entry from it
function platform:spawn_content(content, root_buffer)
    local player_graph = graphs:get_player_graph(self:get_player())
    self:process_content(content, player_graph, #content, root_buffer)
end

function platform:process_content(content, player_graph, content_size, root_buffer)
    while next(content) do
        local index, stat = next(content)
        local directory_entry = self:spawn_stat(stat)
        self.directory_entries[stat.qid.path_hex] = directory_entry
        player_graph:add_entry(self, directory_entry)
        table.remove(content, index)
    end
    local content = root_buffer:process_next({})
    if next(content) then
        content_size = content_size + #content
        minetest.chat_send_player(self:get_player(),
            "read chunk of " .. #content .. " stats for " .. self.platform_string .. " in total of " .. content_size ..
                " up to now")
        minetest.after(2, platform.process_content, self, content, player_graph, content_size, root_buffer)
    else
        minetest.chat_send_player(self:get_player(), "spawned " .. self.platform_string .. " with " ..
            common.table_length(self.directory_entries) .. " entities.")
        minetest.after(1, function()
            self:set_content_size(content_size)
            self:set_external_handler_flag(false)
            self:update()
        end)
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
    local spawn_count = self:get_spawn_count()
    local next_point = spawn_count % 6
    local radius_multiplier = spawn_count / 6
    local radius = 50 + 50 * radius_multiplier
    local angle = (next_point * math.pi) / 3
    if not self.root_point then
        return
    end
    local pos = table.copy(self.root_point)
    pos.y = pos.y + 13
    pos.x = pos.x + radius * math.cos(angle)
    pos.z = pos.z + radius * math.sin(angle)
    return vector.round(pos)
end

-- read directory and spawn platform with directory content 
function platform:spawn(root_point, player, color, paths)
    local root_buffer = buffer(self:get_conn(), self.path)
    local result, content = pcall(root_buffer.process_next, root_buffer, {})
    if not result then
        return
    end
    local size = self:compute_size(content)
    minetest.after(0.5, function()
        common.goto_platform(player, self:get_root_point())
        self:draw(root_point, size, color)
        minetest.after(1, function()
            self:spawn_content(content, root_buffer)
            minetest.show_formspec(player:get_player_name(), "", "")
            if paths then
                minetest.after(0.6, platform.spawn_path_step, self, paths, player)
            end
        end)
    end)
end

-- receives table with paths to spawn platform after platform
-- until there is path in paths 
function platform:spawn_path_step(paths, player)
    local player_graph = graphs:get_player_graph(self:get_player())
    local next = table.remove(paths)
    if not next then
        return
    end
    if not player_graph:get_platform(self.connection.addr .. next) then
        local child_platform = self:spawn_child(next, player, paths)
    else
        local child_platform = player_graph:get_platform(self.connection.addr .. next)
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
function platform:spawn_child(path, player, paths)
    local player_graph = graphs:get_player_graph(self:get_player())
    local child_platform = platform(self.connection, path, self.cmdchan)
    child_platform.node = (player_graph:add_platform(child_platform, self))
    child_platform.properties.player_name = self.properties.player_name
    local pos = self:next_pos()
    if not pos then
        return
    end
    child_platform.mount_point = self.mount_point
    child_platform.origin_point = pos
    child_platform.root_point = pos
    mounts:set_mount_points(self)
    child_platform:spawn(pos, player, self:get_color(), paths)
    self:inc_spawn_count()
    return child_platform
end

-- double the size of the platform. This make available free slots 
function platform:enlarge()
    area_store:remove_area(self.properties.area_id)
    local color = self:get_color()
    local root = self.root_point
    local slots = {}
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
    self.properties.area_id = area_store:insert_area(p1, p2, self.platform_string)
    local core_platform_node = minetest.get_content_id("core:platform")
    local vm = minetest.get_voxel_manip()
    local emin, emax = vm:read_from_map(p1, p2)
    local data = vm:get_data()
    local param2 = vm:get_param2_data()
    local a = VoxelArea:new{
        MinEdge = emin,
        MaxEdge = emax
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
                    local vi = a:index(x, y, z)
                    -- if data[vi] == minetest.CONTENT_IGNORE then 
                    --     print("IGNORED WAS FOUND at " .. dump(p))
                    -- end
                    data[vi] = core_platform_node
                    param2[vi] = color

                    table.insert(slots, p)
                end
            end
        end
    end
    vm:set_data(data)
    vm:set_param2_data(param2)
    vm:write_to_map(true)
    self.size = size
    self.root_point = p1
    table.shuffle(slots)
    self.slots = slots
end

-- when platform node punched, formspec show with table properties
-- :feresh_time - time between platform updates, in seconds
function platform:show_properties(player)
    minetest.show_formspec(player:get_player_name(), "platform:properties",
        table.concat({"formspec_version[3]", "size[10,9.5,false]", "label[4,0.5;Platform settings]",
                      "field[0.5,1;9,0.7;refresh_time;Refresh Frequency;", self.properties.refresh_time, "]",
                      "field[0.5,2.5;9,0.7;external_handler;External Handler;",
                      tostring(self.properties.external_handler), "]", "field[0.5,4;9,0.7;player_name;Player name;",
                      minetest.formspec_escape(self.properties.player_name), "]",
                      "field[0.5,5.5;9,0.7;spawn_platforms;Spawn platforms;",
                      minetest.formspec_escape(self.properties.spawn_platforms), "]", "field[0.5,7;9,0.7;color;Color;",
                      minetest.formspec_escape(self.properties.color), "]", "button_exit[7,8.3;2.5,0.7;save;save]",
                      "field[0,0;0,0;platform_string;;", self.platform_string, "]"}, ""))
end

function platform:update_with_buffer(update_buffer)
    local result, content = pcall(update_buffer.process_next, update_buffer)
    if not result then
        self:wipe()
        return
    end
    if update_buffer:is_open() then
        minetest.after(1, platform.update_with_buffer, self, update_buffer)
    else
        local content_size = #content
        local new_size = self:compute_size(content)
        local new_content = common.qid_as_key(content)
        local stats = self.directory_entries
        local player_graph = graphs:get_player_graph(self:get_player())
        if self.size > 3 and (math.sqrt(content_size) + 3) / self.size < 0.65 then
            self:wipe_top()
            self:delete_nodes()
            area_store:remove_area(self.properties.area_id)
            self:draw(self.origin_point, new_size, self:get_color())
            while next(content) do
                local index, stat = next(content)
                local directory_entry = self:spawn_stat(stat)
                self.directory_entries[stat.qid.path_hex] = directory_entry
                player_graph:add_entry(self, directory_entry)
                table.remove(content, index)
            end
        else
            for qid, st in pairs(new_content) do
                if not stats[qid] then
                    local directory_entry = self:spawn_stat(st)
                    player_graph:add_entry(self, directory_entry)
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
            self:set_content_size(content_size)
        end
        local refresh_time = self:get_refresh_time()
        minetest.after(refresh_time == 0 and 1 or refresh_time, platform.update, self)
    end
end

-- reads directory content and spawn new entities if needed
-- and deletes entities, that are not present in new directory content  
function platform:update()
    local refresh_time = self:get_refresh_time()
    if refresh_time ~= 0 and (not self.properties.external_handler) then
        local update_buffer = buffer(self:get_conn(), self.path)
        minetest.after(0.1, platform.update_with_buffer, self, update_buffer)
    else
        minetest.after(refresh_time == 0 and 1 or refresh_time, platform.update, self)
    end
end

-- check if something is present in correspoing 
-- .lua directory
function platform:load_readdir()
    if not self.mount_point then
        return
    end
    local player_name = self:get_player()
    local lua_readdir = self.path == "/" and self.path:gsub("^/", "/.lua/readdir") or
                            self.path:gsub("^" .. self.mount_point,
                                self.mount_point == "/" and "/.lua/" or self.mount_point .. "/.lua/") .. "/readdir"
    local result, include_string = pcall(np_prot.file_read, self.connection.conn, lua_readdir)
    if result and include_string ~= "" then
        local lua, error = loadstring(include_string)
        if not lua then
            minetest.chat_send_player(player_name, ".lua is not valid: " .. error)
            return
        else
            minetest.chat_send_player(player_name, "Loaded: " .. lua_readdir)
        end
        setfenv(lua, setmetatable({
            platform = self
        }, {
            __index = _G
        }))
        lua()
    elseif include_string == "" then
    else
        minetest.chat_send_player(player_name, "No lua code at path: " .. lua_readdir)
        return
    end
end

function platform:load_getattr(entry, entity)
    if not self.mount_point then
        return
    end
    local player_name = self:get_player()
    local lua_getattr = entry.path:gsub("^" .. self.mount_point,
                            self.mount_point == "/" and "/.lua/" or self.mount_point .. "/.lua/") .. "/getattr"
    local result, include_string = pcall(np_prot.file_read, self.connection.conn, lua_getattr)
    if result and include_string ~= "" then
        local lua, error = loadstring(include_string)
        if not lua then
            minetest.chat_send_player(player_name, ".lua is not valid: " .. error)
            return
        else
            minetest.chat_send_player(player_name, "Loaded: " .. lua_getattr)
        end
        setfenv(lua, setmetatable({
            platform = self,
            entry = entry,
            entity = entity
        }, {
            __index = _G
        }))
        return lua
    elseif include_string == "" then
    else
        minetest.chat_send_player(player_name, "No lua code at path: " .. lua_getattr)
        return
    end
end

function platform:load_read_file(entry, entity, player)
    if not self.mount_point then
        return
    end
    local player_name = self:get_player()
    local lua_read_file = entry.path:gsub("^" .. self.mount_point,
                              self.mount_point == "/" and "/.lua/" or self.mount_point .. "/.lua/") .. "/read_file"
    local result, include_string = pcall(np_prot.file_read, self.connection.conn, lua_read_file)
    if result and include_string ~= "" then
        local lua, error = loadstring(include_string)
        if not lua then
            minetest.chat_send_player(player_name, ".lua is not valid:" .. error)
            return
        else
            minetest.chat_send_player(player_name, "Loaded: " .. lua_read_file)
        end
        setfenv(lua, setmetatable({
            platform = self,
            entry = entry,
            entity = entity,
            player = player
        }, {
            __index = _G
        }))
        lua()
    elseif include_string == "" then
    else
        minetest.chat_send_player(player_name, "No lua code at path: " .. lua_read_file)
        return
    end
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

function platform:inc_spawn_count()
    self.properties.spawn_platforms = self.properties.spawn_platforms + 1
end

function platform:dec_spawn_count()
    self.properties.spawn_platforms = self.properties.spawn_platforms - 1
end

-- Getters

function platform:get_spawn_count()
    return self.properties.spawn_platforms
end

function platform:get_node()
    return self.node
end

function platform:get_refresh_time()
    return self.properties.refresh_time
end

function platform:get_connection()
    return self.connection
end

function platform:get_conn()
    return self.connection.conn
end

function platform:get_cmdchan()
    return self.cmdchan
end

function platform:get_addr()
    return self.connection.addr
end

function platform:get_path()
    return self.path
end

function platform:get_player()
    return self.properties.player_name
end

function platform:get_content_size()
    return self.properties.content_size
end

function platform:get_color()
    return self.properties.color
end

-- Setters
function platform:set_node(node)
    self.node = node
end

function platform:set_color(color)
    self.properties.color = color
end

function platform:set_player(player_name)
    self.properties.player_name = player_name
end

function platform:set_content_size(content_size)
    self.properties.content_size = content_size
end

function platform:set_refresh_time(refresh_time)
    self.properties.refresh_time = refresh_time
end

function platform:set_external_handler_flag(flag)
    self.properties.external_handler = flag
end
