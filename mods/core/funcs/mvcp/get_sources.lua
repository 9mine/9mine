get_sources = function(sources, addr, graph)
    for source_path, source in pairs(sources) do
        local node = graph:findnode(hex(addr .. source_path))
        if node and node.p then
            sources[source_path].node = node
        else
            sources[source_path] = nil
        end
    end
end