list_directory = function(addr, path, player)
    local player_name = player:get_player_name()
    local graph = graphs[player_name]
    local addr_node = graph:findnode(addr)
    local conn = connections[player_name][addr]

    local plt_node = graph:findnode(hex(addr .. path))
    local is_plt = plt_node and plt_node.plt
    if is_plt then
        to_plt(player, plt_node.root)
        return
    end

    -- read directory specified in connection string or root
    local result, response = pcall(readdir, conn, path == "/" and "../" or path)
    if not result then
        send_warning(player_name, response)
        return
    end
    local listing = name_as_key(response or {})

    -- set player above platform and focus view on its 
    local p = player:get_pos()
    p.x = p.x + math.random(-30, 30)
    p.y = p.y + math.random(10, 20)
    p.z = p.z + math.random(-30, 30)
    p = vector.floor(p)

    -- create platform
    local size = plt.get_size(get_table_length(listing))
    local slots, root, size = plt.create(p, size, addr, path)
    to_plt(player, p)
    -- attach host info to the absolute path and hash
    local refresh_time = tonumber(os.getenv("REFRESH_TIME") ~= "" and os.getenv("REFRESH_TIME") or
                                      core_conf:get("refresh_time"))
    minetest.chat_send_player(player_name, "Refresh time is " .. refresh_time)
    local plt_node = graph:node(hex(addr .. path), {
        plt = true,
        listing = listing,
        addr = addr,
        slots = slots,
        root = root,
        size = size,
        path = path,
        addr_path = addr .. path,
        settings = {
            refresh_time = refresh_time
        }
    })

    -- TODO attach to previoud node
    local parent_path = get_parent_path(path)
    local parent_node = graph:findnode(hex(addr .. parent_path))
    if path == "/" then
        graph:edge(addr_node, plt_node, addr .. "->" .. path)
    elseif parent_node then
        graph:edge(parent_node, plt_node, parent_path .. "->" .. path)
    end

    -- handle root path prefix without host
    local prefix = path == "/" and path or path .. "/"

    -- make edges between content of directory and directory itself
    for file_name, file in pairs(listing) do
        local i, slot = next(slots)
        local hash = hex(addr .. prefix .. file_name)
        local file_node = graph:node(hash, {
            stat = file,
            addr = addr,
            path = prefix .. file_name,
            p = slot
        })
        graph:edge(plt_node, file_node, path .. "->" .. file_name)
        spawn_file(file, slot, addr, prefix .. file_name)
        table.remove(slots, i)
    end
    plt_node.slots = slots
    minetest.after(1, platform_refresh, plt_node, addr, path, player_name)
end
