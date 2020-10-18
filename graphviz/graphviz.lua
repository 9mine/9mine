local GraphViz = {} 

GraphViz.__index =  GraphViz


function GraphViz.new() 
  local self = setmetatable({}, GraphViz)
  self.nodes = {}

  self.pos = {
    x = 10,
    y = 10, 
    z = 10
  } 
  self.pos_delta = {
    x = 100,  
    y = 0,
    z = 100
  } 
  
  return self
end

function GraphViz.generate_node_pos(self) 
  return {
    x = self.pos.x + math.random(1,50), 
    y = self.pos.y + math.random(1,50), 
    z = self.pos.z + math.random(1,50) 
--    x = self.pos.x + math.random(self.pos_delta["x"]), 
--    y = self.pos.y + math.random(self.pos_delta["y"]), 
--    z = self.pos.z + math.random(self.pos_delta["z"]) 
  } 
  
end

function GraphViz.register_node(self, node_name)
  minetest.log("GraphViz.register_node, node_name " .. node_name)
  local pos = self.nodes[node_name]
  
  if (pos == nil) then
    pos = self:generate_node_pos() 
    self.nodes[node_name] = pos

    local node_type = "graphviz:node"

    --if string.match(node_name, "...") then
    if string.len(node_name) == 64 then
      node_type = "graphviz:route"
    end

    local node = minetest.add_node(pos, { 
      name = node_type,
      description = node_name
    })
    minetest.get_meta(pos):from_table({
      fields = {
        name = node_name,
      } 
    })
    
  end
  return pos
end

function GraphViz.input(self, record)
  --local from_node_pos = self:register_node(record.graph_node_from)
  --local to_node_pos = self:register_node(record.graph_node_to)
end

function GraphVizNew() 
  return GraphViz.new() 
end
