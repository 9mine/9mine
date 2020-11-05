get_sources = function(sources, addr)
    for source_path in pairs(sources) do
        local node = graph:findnode(hex(addr .. source_path))
        if node and node.p then
            sources[source_path].node = node
        else
            sources[source_path] = nil
        end
    end
end
