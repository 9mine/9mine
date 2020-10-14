list_youtube = function(addr, path, player)
    local player_name = player:get_player_name()
    local graph = graphs[player_name]
    local addr_node = graph:findnode(addr)
    local conn = connections[player_name][addr]

    local plt_node = graph:findnode(md5.sumhexa(addr .. path))
    local is_plt = plt_node and plt_node.plt
    if is_plt then
        to_plt(player, plt_node.root)
        return
    end

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
    -- attach host info to the absolute path and hash
    local plt_node = graph:node(md5.sumhexa(addr .. path), {
        plt = true,
        listing = listing,
        addr = addr,
        root = root,
        size = size,
        path = path,
        addr_path = addr .. path
    })

    -- connect directory to the host node                    
    graph:edge(addr_node, plt_node)

    -- handle root path prefix without host
    local prefix = path == "/" and path or path .. "/"

    -- make edges between content of directory and directory itself
    spawn_youtube(listing["ctl"], {x = root.x + 3, y = root.y, z = root.z + 4},
                  addr, prefix .. listing["ctl"].name)
end
