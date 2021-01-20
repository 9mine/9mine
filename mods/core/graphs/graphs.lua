class 'graphs'

-- container for graphs of all players
function graphs:graphs() self.player_graphs = {} end

-- provided with graph and player name adds graph
-- to container if not exists and returns player graph
function graphs:add_player_graph(graph, player_name)
    if not self.player_graphs[player_name] then
        self.player_graphs[player_name] = graph
    end
    return self.player_graphs[player_name]
end

-- provided with player name return his graph
function graphs:get_player_graph(player_name)
    return self.player_graphs[player_name]
end

