class 'player_graph'

-- initialize player_graph object provided with
-- player name open graph and create graph node
-- with player name as a root_node and return
-- this object
function player_graph:player_graph(player_name)
    self.player_name = player_name
    local g = graph.open(player_name)
    self.graph = g
    self.root_node = g:node(player_name)
    return self
end

-- returns graph object for current player
function player_graph:get_graph() return self.graph end

-- provided with addr string (tcp!host!port) create
-- node and make edge between host addr and root nodes
function player_graph:add_host(attach_string)
    local host_node = self.graph:node(attach_string)
    local result, response = pcall(self.graph.edge, self.graph, self.root_node, host_node)
    if not result then
        minetest.chat_send_player(self.player_name,
                                  "Error graphing edge for host_node: " .. response)
    end
    return host_node
end

-- if platform string provided returns node of
-- corresponding platform. If not provided,
-- returns graph itself
function player_graph:get_node(platform_string)
    if platform_string then
        return self.graph:findnode(platform_string)
    else
        return self.graph
    end
end

-- returns root node of the garph
function player_graph:get_root_node() return self.root_node end

-- provided with platform string returns platform object
function player_graph:get_platform(platform_string)
    local platform_node = self:get_node(platform_string)
    if platform_node then return platform_node.object end
end

-- provided with entry string returns directory entry
function player_graph:get_entry(entry_string)
    local node = self:get_node(entry_string)
    if node then return node.entry end
end

-- adds platform node to the graph. If parent_platform is provided
-- edge made between current platform and parent. If no parent platform
-- provided then edge made between current platform and host node
function player_graph:add_platform(platform, parent_platform, player_host_node)
    local platform_node = self.graph:node(platform.platform_string)
    platform_node.object = platform
    if not parent_platform then
        local result, response = pcall(self.graph.edge, self.graph, player_host_node, platform_node)
        if not result then
            minetest.chat_send_player(self.player_name,
                                      "Error graphing edge before host_node: " .. response)
        end
    else
        local result, response = pcall(self.graph.edge, self.graph, parent_platform:get_node(),
                                       platform_node)
        if not result then
            minetest.chat_send_player(self.player_name,
                                      "Error graphing edge with parent_plat: " .. response)
        end
    end
    return platform_node
end

-- add entry node to the graph and edge made between entry and platform
-- on which entry is spawn
function player_graph:add_entry(platform, directory_entry)
    local platform_node = platform:get_node()
    local entry_node = self.graph:node(directory_entry:get_entry_string())
    entry_node.entry = directory_entry
    directory_entry.node = entry_node
    local result, response = pcall(self.graph.edge, self.graph, platform_node, entry_node)
    if not result then
        minetest.chat_send_player(self.player_name, "Error graphing edge: " .. response)
    end
end

-- provided with platform string, deletes node completely if no
-- entry set to the node. If entry is present, then just the
-- platform object set to nil
function player_graph:delete_node(platform_string)
    local node = self.graph:findnode(platform_string)
    if node and not node.entry then
        node:delete()
    else
        if node then node.object = nil end
    end
end

-- provided with entry string deletes node if no platform
-- is connected with node, else just sets entry property of node to nil
function player_graph:delete_entry_node(entry_string)
    local node = self.graph:findnode(entry_string)
    if node and not node.object then
        node:delete()
    else
        node.entry = nil
    end
end
