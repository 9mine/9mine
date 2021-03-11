local modpath = minetest.get_modpath("graphviz")
local socket = require("socket")

dofile(modpath .. "/graphviz.lua")
dofile(modpath .. "/format_num.lua") 

local graph = GraphVizNew()
total = 0
observer= nil
hud_id = nil


minetest.log("GRAPHVIZ")


show_stats = function()
    if (observer == nil) then
      return
    end 
    if (hud_id ~= nil) then
      observer:hud_remove(hud_id) 
    end
    hud_id = observer:hud_add({
        hud_elem_type = "text",
        --position = {x = 0.8, y = 0.2},
		    offset = {x = 1450, y = 950} ,
        text = string.format("Total on the screen\n%s", format_num(math.floor(total/2), 0, '$')),
        --alignment = {x = 1, y = 0},
        number = 0xFFFFFF,
        --scale = { x = 2, y = 2 },
        size = { x = 3, y = 3 },
    })
end

--function send_chat_msg(msg)


minetest.register_on_joinplayer(function(player)
  player:move_to({x=19.5, y=25, z=13.7}, false)
  player:set_look_vertical(-0.36)
  player:set_look_horizontal(5.5)

  if observer == nil then
    observer = player
    player:hud_add({
      hud_elem_type = "image",
      position = {x = 0, y = 0},
      offset = {x = 1200, y = 1000},
      scale = {x = -30, y = -30},
      alignment = {x = 1, y = 0},
      text = "hud_bg.png"
    })
    show_stats()
  end

  --local player_inventory = player:get_inventory()  
  --player_inventory:add_item("main", "graphviz:node" .. " 1")
end)

function parse_input(input_data) 
  if input_data == nil then
    return
  end
  local args = {}

  minetest.chat_send_all(input_data)
  
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
    value = tonumber(string.sub(args[3], 2))
    	
    total = total + value
    obj:set_nametag_attributes({
      color = "black", 
      text = format_num(value, 2, '$'):gsub('\.00$', '')
    }) 

    if (value > 10000000) then
      local transaction_id = args[1]
      if (#args[2] == 64) then
         transaction_id = args[2]
      end
      transaction_id = "https://www.blockchain.com/btc/tx/" .. transaction_id
      local value1 = format_num(value, 2, '$'):gsub('\.00$', '')
      chat_udp:send(".msg #btc_live " .. value1 .. " " .. transaction_id  .. "\n")
    end

    obj:set_acceleration(vector.direction(from_pos, to_pos))
    minetest.after(15, minetest.remove_node, from_pos) 
    minetest.after(30, minetest.remove_node, to_pos) 
    show_stats()
    minetest.after(45, function(obj, size) 
      obj:remove() 
      total = total - size
    end, obj, value)
  end

end

minetest.register_chatcommand("input", {
  params = "<text>",
  description = "Send text to chat",
  func = function( _ , text)
    minetest.after(1, parse_input, s)
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

chat_udp = socket.udp()
chat_udp:setpeername("192.168.0.108", 6666)
chat_udp:settimeout(0.01)
chat_udp:send(".msg #btc_live stream started!\n")


minetest.register_globalstep(function()
    udp:send(".")
    data = udp:receive()
    if data then
      for s in data:gmatch("[^\r\n]+") do
        minetest.after(0, parse_input, s)
      end
    end
end)
minetest.register_node("graphviz:country_united_kingdom", {
	tiles = { "country_united_kingdom.png" }
})
minetest.register_node("graphviz:country_portugal", {
	tiles = { "country_portugal.png" }
})
minetest.register_node("graphviz:country_jersey", {
	tiles = { "country_jersey.png" }
})
minetest.register_node("graphviz:country_bosnia_and_herzegovina", {
	tiles = { "country_bosnia_and_herzegovina.png" }
})
minetest.register_node("graphviz:country_iceland", {
	tiles = { "country_iceland.png" }
})
minetest.register_node("graphviz:country_panama", {
	tiles = { "country_panama.png" }
})
minetest.register_node("graphviz:country_malta", {
	tiles = { "country_malta.png" }
})
minetest.register_node("graphviz:country_morocco", {
	tiles = { "country_morocco.png" }
})
minetest.register_node("graphviz:country_belarus", {
	tiles = { "country_belarus.png" }
})
minetest.register_node("graphviz:country_tunisia", {
	tiles = { "country_tunisia.png" }
})
minetest.register_node("graphviz:country_new_zealand", {
	tiles = { "country_new_zealand.png" }
})
minetest.register_node("graphviz:country_venezuela", {
	tiles = { "country_venezuela.png" }
})
minetest.register_node("graphviz:country_colombia", {
	tiles = { "country_colombia.png" }
})
minetest.register_node("graphviz:country_germany", {
	tiles = { "country_germany.png" }
})
minetest.register_node("graphviz:country_algeria", {
	tiles = { "country_algeria.png" }
})
minetest.register_node("graphviz:country_hungary", {
	tiles = { "country_hungary.png" }
})
minetest.register_node("graphviz:country_kazakhstan", {
	tiles = { "country_kazakhstan.png" }
})
minetest.register_node("graphviz:country_sweden", {
	tiles = { "country_sweden.png" }
})
minetest.register_node("graphviz:country_uruguay", {
	tiles = { "country_uruguay.png" }
})
minetest.register_node("graphviz:country_nicaragua", {
	tiles = { "country_nicaragua.png" }
})
minetest.register_node("graphviz:country_india", {
	tiles = { "country_india.png" }
})
minetest.register_node("graphviz:country_czech_republic", {
	tiles = { "country_czech_republic.png" }
})
minetest.register_node("graphviz:country_puerto_rico", {
	tiles = { "country_puerto_rico.png" }
})
minetest.register_node("graphviz:country_denmark", {
	tiles = { "country_denmark.png" }
})
minetest.register_node("graphviz:country_norway", {
	tiles = { "country_norway.png" }
})
minetest.register_node("graphviz:country_mexico", {
	tiles = { "country_mexico.png" }
})
minetest.register_node("graphviz:country_luxembourg", {
	tiles = { "country_luxembourg.png" }
})
minetest.register_node("graphviz:country_bulgaria", {
	tiles = { "country_bulgaria.png" }
})
minetest.register_node("graphviz:country_aland_islands", {
	tiles = { "country_aland_islands.png" }
})
minetest.register_node("graphviz:country_brazil", {
	tiles = { "country_brazil.png" }
})
minetest.register_node("graphviz:country_romania", {
	tiles = { "country_romania.png" }
})
minetest.register_node("graphviz:country_spain", {
	tiles = { "country_spain.png" }
})
minetest.register_node("graphviz:country_paraguay", {
	tiles = { "country_paraguay.png" }
})
minetest.register_node("graphviz:country_argentina", {
	tiles = { "country_argentina.png" }
})
minetest.register_node("graphviz:country_poland", {
	tiles = { "country_poland.png" }
})
minetest.register_node("graphviz:country_chile", {
	tiles = { "country_chile.png" }
})
minetest.register_node("graphviz:country_kuwait", {
	tiles = { "country_kuwait.png" }
})
minetest.register_node("graphviz:country_armenia", {
	tiles = { "country_armenia.png" }
})
minetest.register_node("graphviz:country_canada", {
	tiles = { "country_canada.png" }
})
minetest.register_node("graphviz:country_ghana", {
	tiles = { "country_ghana.png" }
})
minetest.register_node("graphviz:country_bolivia", {
	tiles = { "country_bolivia.png" }
})
minetest.register_node("graphviz:country_ukraine", {
	tiles = { "country_ukraine.png" }
})
minetest.register_node("graphviz:country_russian_federation", {
	tiles = { "country_russian_federation.png" }
})
minetest.register_node("graphviz:country_bermuda", {
	tiles = { "country_bermuda.png" }
})
minetest.register_node("graphviz:country_ecuador", {
	tiles = { "country_ecuador.png" }
})
minetest.register_node("graphviz:country_gibraltar", {
	tiles = { "country_gibraltar.png" }
})
minetest.register_node("graphviz:country_reunion", {
	tiles = { "country_reunion.png" }
})
minetest.register_node("graphviz:country_montenegro", {
	tiles = { "country_montenegro.png" }
})
minetest.register_node("graphviz:country_ireland", {
	tiles = { "country_ireland.png" }
})
minetest.register_node("graphviz:country_cambodia", {
	tiles = { "country_cambodia.png" }
})
minetest.register_node("graphviz:country_estonia", {
	tiles = { "country_estonia.png" }
})
minetest.register_node("graphviz:country_kyrgyzstan", {
	tiles = { "country_kyrgyzstan.png" }
})
minetest.register_node("graphviz:country_cyprus", {
	tiles = { "country_cyprus.png" }
})
minetest.register_node("graphviz:country_south_africa", {
	tiles = { "country_south_africa.png" }
})
minetest.register_node("graphviz:country_united_arab_emirates", {
	tiles = { "country_united_arab_emirates.png" }
})
minetest.register_node("graphviz:country_vietnam", {
	tiles = { "country_vietnam.png" }
})
minetest.register_node("graphviz:country_costa_rica", {
	tiles = { "country_costa_rica.png" }
})
minetest.register_node("graphviz:country_netherlands", {
	tiles = { "country_netherlands.png" }
})
minetest.register_node("graphviz:country_finland", {
	tiles = { "country_finland.png" }
})
minetest.register_node("graphviz:country_france", {
	tiles = { "country_france.png" }
})
minetest.register_node("graphviz:country_japan", {
	tiles = { "country_japan.png" }
})
minetest.register_node("graphviz:country_belize", {
	tiles = { "country_belize.png" }
})
minetest.register_node("graphviz:country_united_states", {
	tiles = { "country_united_states.png" }
})
minetest.register_node("graphviz:country_georgia", {
	tiles = { "country_georgia.png" }
})
minetest.register_node("graphviz:country_china", {
	tiles = { "country_china.png" }
})
minetest.register_node("graphviz:country_thailand", {
	tiles = { "country_thailand.png" }
})
minetest.register_node("graphviz:country_serbia", {
	tiles = { "country_serbia.png" }
})
minetest.register_node("graphviz:country_malaysia", {
	tiles = { "country_malaysia.png" }
})
minetest.register_node("graphviz:country_faroe_islands", {
	tiles = { "country_faroe_islands.png" }
})
minetest.register_node("graphviz:country_croatia", {
	tiles = { "country_croatia.png" }
})
minetest.register_node("graphviz:country_british_virgin_islands", {
	tiles = { "country_british_virgin_islands.png" }
})
minetest.register_node("graphviz:country_isle_of_man", {
	tiles = { "country_isle_of_man.png" }
})
minetest.register_node("graphviz:country_israel", {
	tiles = { "country_israel.png" }
})
minetest.register_node("graphviz:country_indonesia", {
	tiles = { "country_indonesia.png" }
})
minetest.register_node("graphviz:country_switzerland", {
	tiles = { "country_switzerland.png" }
})
minetest.register_node("graphviz:country_hong_kong", {
	tiles = { "country_hong_kong.png" }
})
minetest.register_node("graphviz:country_saudi_arabia", {
	tiles = { "country_saudi_arabia.png" }
})
minetest.register_node("graphviz:country_singapore", {
	tiles = { "country_singapore.png" }
})
minetest.register_node("graphviz:country_slovakia", {
	tiles = { "country_slovakia.png" }
})
minetest.register_node("graphviz:country_taiwan", {
	tiles = { "country_taiwan.png" }
})
minetest.register_node("graphviz:country_latvia", {
	tiles = { "country_latvia.png" }
})
minetest.register_node("graphviz:country_seychelles", {
	tiles = { "country_seychelles.png" }
})
minetest.register_node("graphviz:country_turkey", {
	tiles = { "country_turkey.png" }
})
minetest.register_node("graphviz:country_greece", {
	tiles = { "country_greece.png" }
})
minetest.register_node("graphviz:country_russia", {
	tiles = { "country_russia.png" }
})
minetest.register_node("graphviz:country_lithuania", {
	tiles = { "country_lithuania.png" }
})
minetest.register_node("graphviz:country_andorra", {
	tiles = { "country_andorra.png" }
})
minetest.register_node("graphviz:country_mongolia", {
	tiles = { "country_mongolia.png" }
})
minetest.register_node("graphviz:country_kenya", {
	tiles = { "country_kenya.png" }
})
minetest.register_node("graphviz:country_italy", {
	tiles = { "country_italy.png" }
})
minetest.register_node("graphviz:country_australia", {
	tiles = { "country_australia.png" }
})
minetest.register_node("graphviz:country_austria", {
	tiles = { "country_austria.png" }
})
minetest.register_node("graphviz:country_belgium", {
	tiles = { "country_belgium.png" }
})
minetest.register_node("graphviz:country_saint_lucia", {
	tiles = { "country_saint_lucia.png" }
})
minetest.register_node("graphviz:country_slovenia", {
	tiles = { "country_slovenia.png" }
})
minetest.register_node("graphviz:country_philippines", {
	tiles = { "country_philippines.png" }
})
