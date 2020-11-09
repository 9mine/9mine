class 'platforms'

function platforms:platforms(graph)
    local platforms_graph = graph.open("platforms")
    self.graph = platforms_graph
    self.root_node = platforms_graph:node("platforms")
end

function platforms:get(connection_string)
    if connection_string then
        return self.graph:findnode(connection_string)
    else
        return self.graph
    end
end

function platforms:get_root()
    return self.root_node
end

function platforms:add(platform, parent_platform)
    local platform_node = self.graph:node(platform.connection_string)

    if not parent_platform then
        local host_node = self.graph:findnode(platform.conn.addr)
        self.graph:edge(host_node, platform_node)
    else
        self.graph:edge(parent_platform, platform_node)
    end
    return platform_node
end

function platforms:add_host(attach_string)
    if not self.graph:findnode(attach_string) then
        local host_node = self.graph:node(attach_string)
        self.graph:edge(self.root_node, host_node)
    end
end
