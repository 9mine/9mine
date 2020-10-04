local GraphVizNode = {} 
GraphVizNode.__index = GraphVizNode

function GraphVizNode.new() 
  local self = setmetatable({}, GraphViz)
end

