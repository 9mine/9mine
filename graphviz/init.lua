local modpath = minetest.get_modpath("graphviz")
local socket = require("socket")

dofile(modpath .. "/graphviz.lua")

local graph = GraphVizNew()


minetest.log("GRAPHVIZ")




minetest.register_on_joinplayer(function(player)
  --local player_inventory = player:get_inventory()  
  --player_inventory:add_item("main", "graphviz:node" .. " 1")
end)

function parse_input(input_data) 
  if input_data == nil then
    return
  end
  local args = {}
  
  for w in string.gmatch(input_data, "[^%s]+") do
    table.insert(args, w)
  end


  if (#args >= 1) then
    from_pos = graph:register_node(args[1]) 
  end
  if (#args >= 2) then
    to_pos = graph:register_node(args[2]) 
  end
  if (#args >= 3) then
    node = minetest.get_node(from_pos) 
    local obj = minetest.add_entity(from_pos, "graphviz:item")
    obj:set_properties({
      infotext = args[2]
    })
    obj:set_nametag_attributes({color = "black", text = args[3]})
    obj:set_acceleration(vector.direction(from_pos, to_pos))
    minetest.after(15, minetest.remove_node, from_pos) 
    minetest.after(25, minetest.remove_node, to_pos) 
  end

end

minetest.register_chatcommand("input", {
  params = "<text>",
  description = "Send text to chat",
  func = function( _ , text)
    parse_input(text) 
    return true, nil
  end,
})



minetest.register_node("graphviz:node", {
  tiles = { "graphviz_node.png" },
  --on_construct = function(pos) 
    --minetest.after(5, minetest.remove_node, pos)
  --end,
  --on_destruct = function() 
  --  minetest.log("NODE DESCTRUCT")
  --end
}) 

minetest.register_entity("graphviz:item", {
  	initial_properties = {
        physical = false,
        pointable = true,
        visual = "sprite",
        collide_with_objects = true,
        textures = {"graphviz_packet.png"},
        spritediv = {x = 1, y = 1},
        initial_sprite_basepos = {x = 0, y = 0},
        is_visible = true,
        makes_footstep_sound = false,
        nametag_color = "black",
        infotext = "",
        static_save = true,
        shaded = true
    },



    hp_max = 1,
    drawtype = "front",
    physical = false,
    weight = 5,
    --collisionbox = {-0.5,-0.5,-0.5, 0.5,0.5,0.5},
    visual = "cube",
    visual_size = {x=1, y=1},
    --textures = { "graphviz_packet.png",  "graphviz_packet.png", "graphviz_packet.png", "graphviz_packet.png", "graphviz_packet.png", "graphviz_packet.png"}, -- number of required textures depends on visual
    textures = { "graphviz_packet.png"}, -- number of required textures depends on visual
    on_step = function (self, dtime)
      local node = minetest.get_node(self.object:get_pos())
      local properties = self.object:get_properties() 
      if (node ~= nil) then
        local nodeMetaDataRef = minetest.get_meta(self.object:get_pos()):to_table()    
        if (nodeMetaDataRef and nodeMetaDataRef["fields"] and nodeMetaDataRef["fields"]["name"] == properties["infotext"] ) then
          self.object:remove()
          minetest.log("remove obj")
        end 
        --minetest.log(inspect(nodeMetaDataRef:to_table()))
      
      end
    end,
    spritediv = {x=1, y=1},
    initial_sprite_basepos = {x=0, y=0},
    is_visible = true,
    makes_footstep_sound = false,
    --automatic_rotate = false,
})

minetest.register_node("graphviz:node", {
  tiles = { "graphviz_node.png" },
})

minetest.register_node("graphviz:route", {
  tiles = { "graphviz_route.png" },
})

udp = socket.udp()
udp:setpeername("127.0.0.1", 5555)
udp:settimeout(0.01)

minetest.register_globalstep(function()
    udp:send(".")
    data = udp:receive()
    if data then
      for s in data:gmatch("[^\r\n]+") do
        parse_input(s)
        print(s)
      end
    end
end)


