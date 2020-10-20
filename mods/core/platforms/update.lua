plt.update = function(addr, path, player_name)
    local graph = graphs[player_name]
    local addr_node = graph:findnode(addr)
    local conn = connections[player_name][addr]
    local plt_node = graph:findnode(hex(addr .. path))
    local old_lst = plt_node and plt_node.listing
    local slots = plt_node and plt_node.slots

    local new_lst = name_as_key(readdir(conn, path == "/" and "../" or path) or
                                    {})
    local prefix = path == "/" and path or path .. "/"

    for name, file in pairs(new_lst) do
        if old_lst[name] == nil then
            local i, slot = next(slots)
            local hash = hex(addr .. prefix .. file.name)
            local file_node = graph:node(hash, {
                stat = file,
                addr = addr,
                path = prefix .. file.name,
                p = slot
            })
            graph:edge(plt_node, file_node, path .. "->" .. file.name)
            spawn_file(file, slot, addr, prefix .. file.name)
            table.remove(slots, i)
            old_lst[name] = file
        else
            local file_node = graph:findnode(hex(addr .. prefix .. file.name))
            local e = minetest.get_objects_inside_radius(file_node.p, 1.2)[1]
            if not e then
                spawn_file(file, file_node.p, addr, prefix .. file.name)
            end
        end
    end

    for name, file in pairs(old_lst) do
        if new_lst[name] == nil then
            local hash = hex(addr .. prefix .. file.name)
            local file_node = graph:findnode(hash)
            table.insert(slots, file_node.p)
            remove_file(file_node.p)
            local edge_file_node = file_node:nextinput(nil)
            edge_file_node:delete()
            old_lst[name] = nil
        end
    end

end
