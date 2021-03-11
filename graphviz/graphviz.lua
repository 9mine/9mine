local GraphViz = {} 

GraphViz.__index =  GraphViz

countries = {"country_united_kingdom","country_portugal","country_jersey","country_bosnia_and_herzegovina","country_iceland","country_panama","country_malta","country_morocco","country_belarus","country_tunisia","country_new_zealand","country_venezuela","country_colombia","country_germany","country_algeria","country_hungary","country_kazakhstan","country_sweden","country_uruguay","country_nicaragua","country_india","country_czech_republic","country_puerto_rico","country_denmark","country_norway","country_mexico","country_luxembourg","country_bulgaria","country_aland_islands","country_brazil","country_romania","country_spain","country_paraguay","country_argentina","country_poland","country_chile","country_kuwait","country_armenia","country_canada","country_ghana","country_bolivia","country_ukraine","country_russian_federation","country_bermuda","country_ecuador","country_gibraltar","country_reunion","country_montenegro","country_ireland","country_cambodia","country_estonia","country_kyrgyzstan","country_cyprus","country_south_africa","country_united_arab_emirates","country_vietnam","country_costa_rica","country_netherlands","country_finland","country_france","country_japan","country_belize","country_united_states","country_georgia","country_china","country_thailand","country_serbia","country_malaysia","country_faroe_islands","country_croatia","country_british_virgin_islands","country_isle_of_man","country_israel","country_indonesia","country_switzerland","country_hong_kong","country_saudi_arabia","country_singapore","country_slovakia","country_taiwan","country_latvia","country_seychelles","country_turkey","country_greece","country_russia","country_lithuania","country_andorra","country_mongolia","country_kenya","country_italy","country_australia","country_austria","country_belgium","country_saint_lucia","country_slovenia","country_philippines"}


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
      --node_type = "graphviz:route"
      node_type = "graphviz:" .. countries[ math.random( #countries ) ]
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
