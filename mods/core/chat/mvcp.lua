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

function mvcp:set_destination_platform()
    local destination = platforms:get_platform(self.addr .. self.destination)
    if not destination then
        local result, response = pcall(np_prot.stat_read, self.attachment, self.destination)
        if not result then
            local parent_path = self:get_parent_path()
            destination = platforms:get_platform(self.addr .. parent_path)
        elseif response.qid.type ~= 128 then
            local parent_path = self:get_parent_path()
            destination = platforms:get_platform(self.addr .. parent_path)
        end
    end
    self.destination_platform = destination
    return destination
end

function mvcp:get_parent_path()
    if self.destination == "/" then
        return "/"
    end
    local parent = self.destination:match('.*/')
    if parent == "/" then
        return "/"
    end
    return parent:match('.*[^/]')
end

function mvcp:get_changes()
    local changes = {}
    local stats = self.destination_platform:get_stats()
    local new_content = common:qid_as_key(self.destination_platform:readdir())
    for qid, st in pairs(new_content) do
        if not stats[qid] then
            changes[qid] = st
        elseif stats[qid].stat.version ~= st.version or stats[qid].stat.name ~= st.name then
            changes[qid] = st
        end
    end
    print(dump(changes))
end

local move = function(player_name, params)
    local platform = platforms:get_platform(common:get_platform_string(minetest.get_player_by_name(player_name)))
    local mvcp = mvcp(platform)
    mvcp:parse_params(params)
    local cmdchan = platform:get_cmdchan()
    local path = platform:get_path()
    if not mvcp:set_destination_platform() then
        minetest.chat_send_all(cmdchan:execute("mv " .. params, path))
        return true, "No Destination Platform Found. MV handled by platform refresh"
    else
        minetest.chat_send_all(cmdchan:execute("mv " .. params, path))
        mvcp:get_changes()
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
