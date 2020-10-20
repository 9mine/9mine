graph_changes = function(changes, changes_path, addr, graph)
    local plt_node = graph:findnode(hex(addr .. changes_path))
    local slots = plt_node.slots
    local prefix = changes_path == "/" and changes_path or changes_path .. "/"
    local pfx = addr .. prefix
    for name, value in pairs(changes) do
        local index, slot = next(slots)
        local node = graph:findnode(hex(pfx .. name))
        if not node then
            local file_node = graph:node(hex(pfx .. name), {
                stat = value.stat,
                addr = addr,
                path = prefix .. name,
                p = slot
            })
            graph:edge(plt_node, file_node, plt_node.path .. "->" .. name)
            plt_node.listing[name] = value.stat
            table.remove(slots, index)
        else
            node.stat = value.stat
            local edge_node = node:nextinput(nil)
            edge_node:delete()
            graph:edge(plt_node, node, plt_node.path .. "->" .. name)
            plt_node.listing[name] = value.stat or value
        end
    end
end
