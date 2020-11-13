class 'mvcp'

-- analyzes destination path to decide if needed to go 
-- one level up on fs structure
function mvcp:get_destination_platform()
    -- check if source only one 
    local source_entry
    if #self.sources == 1 and not self.globbed and not self.recursive then
        source_entry = platforms:get_entry(self.addr .. self.sources[1])
    end
    -- check if destination entry is spawned
    local result, stat =
        pcall(np_prot.stat_read, self.attachment, self.destination == "/" and "../" or self.destination)

    -- decide if destination itself should be tracked for changes or 
    -- parent directory of destination
    if result then
        if stat.qid.type ~= 128 or (source_entry and source_entry.stat.qid.type == 128) then
            self.destination_platform = platforms:get_platform(self.addr .. mvcp.get_parent_path(self.destination))
        elseif self.recursive and not platforms:get_entry(self.addr .. self.destination) then
            self.destination_platform = platforms:get_platform(self.addr .. mvcp.get_parent_path(self.destination))
        else
            self.destination_platform = platforms:get_platform(self.addr .. self.destination)
        end
    end
    return self.destination_platform
end

-- traverse changed files and find corresponding source entry
function mvcp:map_changes(changes)
    -- if rename was intended, delete all other changes 
    -- that occured not by mv/cp command 
    if self.destination ~= self.destination_platform.path then
        local destination_name = self.destination:match("[^/]%w+$")
        for qid, change in pairs(changes) do
            if change.name ~= destination_name then
                changes[qid] = nil
                break
            end
        end
    end

    for qid, change in pairs(changes) do
        local source_entry, destination_entry, pos
        -- if destination path and destination platform path different 
        -- means destination file name was named directly 
        if self.destination ~= self.destination_platform.path then
            minetest.chat_send_all("Exact name found. Renaming . . .")
            source_entry = platforms:get_entry(self.addr .. self.sources[1])
            destination_entry = platforms:get_entry(self.addr .. self.destination)
        else
            minetest.chat_send_all("No exact name provided, map by original entries name")
            source_entry = self.platform:get_entry_by_name(change.name)
            destination_entry = self.destination_platform:get_entry_by_name(change.name)
        end

        if source_entry then
            -- remove destination entry entity
            local directory_entry = source_entry:copy()
            -- delete entry record from source platform
            if self.command == "mv" then
                self.platform:delete_entry(source_entry)
                source_entry:delete_node()
            end

            local entity = self.platform:get_entity_by_pos(directory_entry.pos)

            -- if destination entry exists, use their position and remove entity 
            -- else get new free slot from platform
            if destination_entry then
                pos = destination_entry:get_pos()
                -- remove destination entity with corresponding recond in
                -- platform directory_entries table
                self.destination_platform:remove_entity(destination_entry:get_qid())
            else
                pos = self.destination_platform:get_slot()
            end

            -- if cp command, duplicate entity
            if self.command == "cp" then
                entity = mvcp.copy(entity)
            end

            directory_entry:set_pos(pos):set_stat(change)

            -- configure and set source entry to the destination platform
            self.destination_platform:inject_entry(directory_entry)

            -- update graph
            platforms:add_directory_entry(self.destination_platform, directory_entry)
            -- animate 
            common.flight(entity, directory_entry)
        end

    end
end

local move = function(player_name, command, params)
    if command == "mv" or command == "cp" then
        local platform = platforms:get_platform(common.get_platform_string(minetest.get_player_by_name(player_name)))
        local mvcp = mvcp(platform, command, params):parse_params()
        local cmdchan = platform:get_cmdchan()

        -- execute mv/cp command and send output (if any) to the minetest console 
        minetest.chat_send_all(cmdchan:execute(command .. " " .. params, platform:get_path()))

        -- if not destination platform was chosen, leave handling for platform refresh
        if not mvcp:get_destination_platform() then
            return true
        end

        -- get stats of files, that was changed after mv/cp command execution
        -- either new QID is present, or if existing file name was changed
        -- or vile version is different
        local changes = mvcp:get_changes(mvcp.destination_platform)

        -- reduce sources which are on same platform
        mvcp:reduce()
        for index, source in pairs(mvcp.reduced_sources) do
            mvcp.platform = platforms:get_platform(mvcp.addr .. source)
            mvcp:map_changes(changes)
        end

        -- set external_handler flag to false for all sources and destination platforms
        for _, source in pairs(mvcp.reduced_sources) do
            platforms:get_platform(platform:get_addr() .. source).external_handler = false
        end

        mvcp.destination_platform.properties.external_handler = false

        return true
    end
end
minetest.register_on_chatcommand(move)
-- Takes as input chat message, and sets and returns absolute path 
-- for sources and destination 
function mvcp:parse_params()
    local destination = {}
    local sources = {}
    for w in self.params:gmatch("[^ ]+") do
        if w:match("^%-") then
            self.recursive = true
            print("RECURSIVE was set")
        elseif w:match("^%*$") then
            self.globbed = true
            table.insert(sources, w)
        elseif w:match("^%.$") then
            w = self.path
            destination = w
            table.insert(sources, w)
        else
            w = w:match("^%./") and w:gsub("^%./", self.path == "/" and self.path or self.path .. "/") or w
            if not w:match("^/") then
                w = self.path:match("/$") and self.path .. w or self.path .. "/" .. w
            end
            destination = w
            table.insert(sources, w)
        end
    end
    table.remove(sources)
    if destination:len() > 1 and destination:match('/$') then
        destination = destination:match('.*[^/]')
    end
    if destination:match('^%.$') then
        destination = self.path
    end
    self.destination = destination
    self.sources = sources
    return self
end

-- return changes which occures on provided platform after execution on cmdchan command 
function mvcp:get_changes(platform)
    local platform = platform
    -- set external_handler flag on platform where changes will be read
    platform.properties.external_handler = true
    local changes = {}
    local stats = platform.directory_entries
    local content_new = common.qid_as_key(platform:readdir())
    for qid, st in pairs(content_new) do
        if (not stats[qid]) or (stats[qid].stat.qid.version ~= st.qid.version or stats[qid].stat.name ~= st.name) then
            changes[qid] = st
        end
    end
    return changes
end

-- If multiple sources for mvcp provided, reduces to 1 sources with same platform
function mvcp:reduce()
    local reduced_sources = {}
    local temp = {}
    for index, source in pairs(self.sources) do
        if source == "*" then
            table.insert(reduced_sources, self.path)
        else
            local parent_source = mvcp.get_parent_path(source)
            if not temp[parent_source] then
                temp[parent_source] = 1
                table.insert(reduced_sources, parent_source)
            end
        end
    end
    self.reduced_sources = reduced_sources
    return reduced_sources
end

-- provided with path string, returns path on level up 
-- on fs structure
function mvcp.get_parent_path(path)
    if path == "/" then
        return "/"
    end
    local parent = path:match('.*/')
    if parent == "/" then
        return "/"
    end
    return parent:match('.*[^/]')
end

function mvcp.copy(stat_entity)
    local pos = stat_entity:get_pos()
    local entity = minetest.add_entity(pos, "core:stat")
    return entity
end

function mvcp:mvcp(platform, command, params)
    self.command = command
    self.params = params
    self.recursive = false
    self.platform = platform
    self.addr = platform:get_addr()
    self.path = platform:get_path()
    self.attachment = platform:get_attachment()
    return self
end
