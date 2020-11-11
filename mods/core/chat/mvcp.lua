class 'mvcp'

function mvcp:mvcp(platform)
    self.platform = platform
    self.addr = platform:get_addr()
    self.path = platform:get_path()
    self.attachment = platform:get_attachment()
end

function mvcp:parse_params(chat_string)
    local destination = {}
    local sources = {}
    local params = {}
    for w in chat_string:gmatch("[^ ]+") do
        if w:match("^%-") then
            table.insert(params, w)
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
    self.params = params

    return self.sources, self.destination, self.params
end

function mvcp:is_destination_platform()
    return platforms:get_platform(self.addr .. self.destination)
end

function mvcp:get_destination_platform()
    local destination = platforms:get_platform(self.addr .. self.destination)
    if not destination then
        local result, response = pcall(np_prot.stat_read, self.attachment, self.destination)
        if not result then
            local parent_path = mvcp.get_parent_path(self.destination)
            destination = platforms:get_platform(self.addr .. parent_path)
        elseif response.qid.type ~= 128 then
            local parent_path = mvcp.get_parent_path(self.destination)
            destination = platforms:get_platform(self.addr .. parent_path)
        end
    end
    self.destination_platform = destination
    return destination
end

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

function mvcp:get_sources()
    for source_path in pairs(self.sources) do
        local directory_entry_node = platforms:get_directory_entry(addr .. source_path)
        if directory_entry_node and directory_entry_node.entry then
            sources[directory_entry_node.stat.name] = node
        else
            sources[directory_entry_node.stat.name] = nil
        end
    end
end

function mvcp.get_changes(platform)
    local changes_new = {}
    local changes_removed = {}
    local stats = platform.directory_entries
    local new_content = platform:readdir()
    local new_content_qid = common.qid_as_key(new_content)
    local new_content_name = common.name_as_key(new_content)
    for qid, st in pairs(new_content_qid) do
        if not stats[qid] then
            changes_new[qid] = st
        elseif stats[qid].stat.version ~= st.version or stats[qid].stat.name ~= st.name then
            changes_new[qid] = st
        end
    end

    for qid, stat in pairs(stats) do
        if not new_content_qid[qid] then
            changes_removed[stat.stat.name] = stat
        end
    end

    return changes_new, changes_removed
end

function mvcp.inplace(destination_platform, changes)
    for qid, change in pairs(changes) do
        if destination_platform.directory_entries[qid] then
            local directory_entry = destination_platform.directory_entries[qid]
            local stat_entity = destination_platform:get_entity_by_qid(qid)
            directory_entry:set_stat(change)
            destination_platform:configure_entry(directory_entry)
            common.flight(stat_entity, directory_entry)
        end
    end
end

function mvcp.from_one_source(changes_removed, changes_new, source_platform, destination_platform)
    for qid, change in pairs(changes_new) do
        if changes_removed[change.name] then
            local entry_string
            if source_platform.platform_string:match("/$") then
                entry_string = source_platform.platform_string .. change.name
            else
                entry_string = source_platform.platform_string .. "/" .. change.name
            end
            local directory_entry = platforms:get_entry(entry_string)
            local stat_entity = source_platform:get_entity_by_name(change.name)
            local slot = (destination_platform:get_slot())
            directory_entry:set_pos(slot)
            destination_platform:configure_entry(directory_entry)
            destination_platform.directory_entries[change.qid.path_hex] = directory_entry
            common.flight(stat_entity, directory_entry)
        end
    end
end

local move = function(player_name, params)
    local platform = platforms:get_platform(common.get_platform_string(minetest.get_player_by_name(player_name)))
    local mvcp = mvcp(platform)
    mvcp:parse_params(params)
    local cmdchan = platform:get_cmdchan()
    local path = platform:get_path()
    local destination_platform = mvcp:get_destination_platform()
    if not destination_platform then
        minetest.chat_send_all(cmdchan:execute("mv " .. params, path))
        return true, "No Destination Platform Found. MV handled by platform refresh"
    else
        minetest.chat_send_all(cmdchan:execute("mv " .. params, path))
        local destination_new = mvcp.get_changes(destination_platform)
        if #mvcp.sources == 1 then
            minetest.chat_send_all("One source. Checking if same with destination")
            local index, source = next(mvcp.sources)
            local parent_source = mvcp.get_parent_path(source)
            local parent_platform = platforms:get_platform(platform:get_addr() .. parent_source)
            if parent_platform == destination_platform then
                minetest.chat_send_all("Same platform. Handle inplace (renaming)")

                mvcp.inplace(platform, new)
            else
                minetest.chat_send_all("Not same. Getting changes from sources")
                local new, removed = mvcp.get_changes(parent_platform)
                mvcp.from_one_source(removed, destination_new, parent_platform, destination_platform)
            end
        end

    end
    -- get_sources(sources, addr)
    -- get_destination(destination, addr)
    -- cmd_write(addr, path, player_name, "mv " .. params, lcmd)
    -- local changes, changes_path = get_changes(destination, addr, player_name)
    -- if changes then
    --     graph_changes(changes, changes_path, addr)
    -- end
    -- local result, response = pcall(map_changes_to_sources, sources, changes, addr)
    -- if not result then
    --     send_warning(player_name, response)
    -- end

end

minetest.register_chatcommand("mv", {
    func = move
})
