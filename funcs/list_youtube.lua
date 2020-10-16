list_youtube = function(addr, path, player)
    local name = player:get_player_name()
    local g = graphs[name]
    local addr_node = g:findnode(addr)
    local conn = connections[name][addr]

    local listing = name_as_key(readdir(conn, path == "/" and "../" or path) or
                                    {})

    local p = player:get_pos()
    p.x = p.x + math.random(-10, 10)
    p.y = p.y + math.random(0, 5)
    p.z = p.z + math.random(-10, 10)
    p = vector.floor(p)

    local slots, root, size = plt.create(p, 10, addr, path)
    to_plt(player, p)
    local prefix = path == "/" and path or path .. "/"
    local ctl_p = {x = root.x + 3, y = root.y + 1, z = root.z + 4}

    local plt_node = g:node(hex(addr .. path), {
        plt = true,
        listing = listing,
        addr = addr,
        root = root,
        size = size,
        path = path,
        slots = slots,
        addr_path = addr .. path,
        ctl_path = prefix .. "ctl",
        ctl_p = ctl_p,
        result_path = prefix .. "result"
    })

    g:edge(addr_node, plt_node)
    spawn_youtube(listing["ctl"], ctl_p, addr, plt_node.ctl_path)
end
