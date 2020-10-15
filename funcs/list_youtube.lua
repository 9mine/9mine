list_youtube = function(addr, path, player)
    local name = player:get_player_name()
    local g = graphs[name]
    local addr_node = g:findnode(addr)
    local conn = connections[name][addr]

    -- read directory specified in connection string or root
    local listing = name_as_key(readdir(conn, path == "/" and "../" or path) or
                                    {})
    
    -- set player above platform and focus view on its 
    local p = player:get_pos()
    p.x = p.x + math.random(-10, 10)
    p.y = p.y + math.random(0, 5)
    p.z = p.z + math.random(-10, 10)
    p = vector.floor(p)

    -- create platform
    local _, root, size = plt.create(p, 10, addr, path)
    to_plt(player, p)
    local prefix = path == "/" and path or path .. "/"
    local ctl_p = {x = root.x + 3, y = root.y + 1, z = root.z + 4}
    local result_p = {x = root.x + 6, y = root.y + 1, z = root.z + 4}

    -- attach host info to the absolute path and hash
    local plt_node = g:node(md5.sumhexa(addr .. path), {
        plt = true,
        listing = listing,
        addr = addr,
        root = root,
        size = size,
        path = path,
        addr_path = addr .. path,
        ctl_path = prefix .. "ctl",
        ctl_p = ctl_p,
        result_path = prefix .. "result",
        result_p = result_p
    })

    -- connect directory to the host node                    
    g:edge(addr_node, plt_node)

    -- handle root path prefix without host

    -- make edges between content of directory and directory itself
    spawn_youtube(listing["ctl"], ctl_p, addr, prefix .. listing["ctl"].name)
end
