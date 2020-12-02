class 'player_graph'

function player_graph:player_graph(player_name)
    local g = graph.open("player_name")
    self.graph = g
    self.root_node = g:node("player_name")
    return self
end
