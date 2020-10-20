map_changes_to_sources = function(sources, changes, destination, addr, graph,
                                  command)
    local path, kv_changes = next(changes)
    local path_node = graph:findnode(hex(addr .. path))
    path = path == "/" and path or path .. "/"

    for path, value in pairs(sources) do
        if changes[value.node.stat.name] then
            local p1 = value.node.p
            local path = changes[value.node.stat.name].path
            path = path == "/" and path or path .. "/"
            local file_node = graph:findnode(
                                  hex(addr .. path .. value.node.stat.name))
            if file_node and file_node.p then
                local pp1 = table.copy(p1)
                pp1.y = pp1.y + 1
                local entity = get_entity(pp1)
                if command == "cp" then
                    entity = copy_entity(entity, path .. value.node.stat.name,
                                         changes[value.node.stat.name].stat)
                end
                flight(entity, file_node.p)
                local pp2 = table.copy(file_node.p)
                pp2.y = pp2.y + 1
                local result, entity = pcall(get_entity, pp2)
                if entity then entity:remove() end
            end
        else
            local name, val = next(changes)
            path = val.path == "/" and val.path or val.path .. "/"
            local file_node = graph:findnode(hex(addr .. path .. val.stat.name))
            local pp1 = table.copy(value.node.p)
            pp1.y = pp1.y + 1
            local entity = get_entity(pp1)
            if command == "cp" then
                entity = copy_entity(entity, path .. val.stat.name, val.stat)
            else
                entity:set_properties({nametag = val.stat.name})
            end
            flight(entity, file_node.p)
            local pp2 = table.copy(file_node.p)
            pp2.y = pp2.y + 1
            local result, entity = pcall(get_entity, pp2)
            if entity then entity:remove() end
        end
    end
end
