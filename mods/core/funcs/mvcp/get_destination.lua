get_destination = function(destination, addr, graph)
    local destination_path, destination_value = next(destination)
    local node = graph:findnode(hex(addr .. destination_path))
    if node then
        destination[destination_path].plt = node.plt or false
        if node.p then destination[destination_path].node = node end
        if node:nextinput(nil) then
            destination[destination_path].parent_path =
                node:nextinput(nil).tail.path
            destination[destination_path].parent_node = node:nextinput(nil).tail
        end
    else
        local parent_path = get_parent_path(destination_path)
        destination[destination_path].parent_path = parent_path
        local parent_node = graph:findnode(hex(addr .. parent_path))
        destination[destination_path].parent_node = parent_node
    end
end
