class 'graphs'

function graphs:graphs()
    self.graphs = {}
end

function graphs:add_graph(graph, player_name)
    if not self.graphs[player_name] then
        self.graphs[player_name] = graph 
    end
    return self.graphs[player_name]
end

function graphs:get_graph(player_name)
    return self.graphs[player_name]
end
