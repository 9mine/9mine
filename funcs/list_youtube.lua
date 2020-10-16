list_youtube = function(addr, path, player)
    local name = player:get_player_name()
    local g = graphs[name]
    local addr_node = g:findnode(addr)
    local conn = connections[name][addr]
    local pos = player:get_pos()
    local slots, root, size = plt.create(pos, 12, addr, path)
    to_plt(player, pos)
    local prefix = path == "/" and path or path .. "/"
    local ctl_pos = {x = root.x + 3, y = root.y + 1, z = root.z + 4}

    local plt_node = g:node(hex(addr .. path), {
        plt = true,
        listing = name_as_key(readdir(conn, path == "/" and "../" or path) or {}),
        addr = addr,
        root = root,
        size = size,
        path = path,
        slots = slots,
        ctl_pos = ctl_pos,
        ctl_path = prefix .. "ctl",
        addr_path = addr .. path,
        result_path = prefix .. "result"
    })

    g:edge(addr_node, plt_node)
    spawn_youtube(plt_node.listing["ctl"], ctl_pos, addr, plt_node.ctl_path)
end
