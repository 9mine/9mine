local ninepchat = {}
local socket = require("socket")
local pprint = require("pprint")

ninepchat.__index = ninepchat 

function ninepchat.new(ipaddr, port, pos, size) 
  local self = setmetatable({}, ninepchat)

  self.udp = socket.udp()
  self.udp:setpeername(ipaddr, port)
  self.udp:settimeout(0.01)
  self.addr = ipaddr
  self.port = port
  self.chat = {}
  self.lifetime = 45
  self.npcf_id = 1

  self.pos = pos
  self.size = size


  minetest.register_globalstep(function()
    self.udp:send(".")
    local data = self.udp:receive()
    if data then
      for chat_line in data:gmatch("[^\r\n]+") do
        self:parse(chat_line) 
      end
    end
  end)

  minetest.after(5, ninepchat.terra, self)

  return self
end

function ninepchat.terra(self) 
  minetest.log("ninepchat.terra") 
  --local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
  --local data = vm:get_data()
  --local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})

  self.n = 1
  --self.pos = {}
  
  for x = self.pos.x, self.pos.x + self.size.x - 1 do
    for y = self.pos.y, self.pos.y + self.size.y - 1 do
      for z = self.pos.z, self.pos.z + self.size.z - 1 do
        minetest.log("Add 9pzone:chat node on " .. x .. "," .. y .. "," .. z) 
        minetest.add_node(
          { x = x, y = y, z = z }, { name = "9pzone:chat" }
        ) 
        --self.[self.n] = { x = x, y = y, z = z }
        --self.n = self.n + 1
      end
    end
  end

  --vm:set_data(data)
  --vm:write_to_map()
   
end

function life_timer(chat, user_name) 
  local last_time = chat.chat[user_name]["last_time"]  

  local npcf_id = chat.chat[user_name]["npcf_id"]
  local npcf_ref = npcf.npcs[npcf_id]
  
  pprint(npcf_id)
  pprint(npcf_ref)
  mvobj = npcf.movement.getControl(npcf_ref)

  mvobj:lay()
  mvobj:look_to({ x = 13, y = 13, z = 13 })

  if (os.time() - last_time < chat.lifetime) then
    minetest.log(user_name .. " is still life ")
    minetest.after(5, life_timer, chat, user_name)
    return
  end

  minetest.log("----")
  pprint(chat.chat[user_name])
  minetest.log("----")
  minetest.log("Removed " .. user_name .. " by timer " .. tostring(last_time))
  npcf:unload(chat.chat[user_name]["npcf_id"])
  chat.chat[user_name] = nil
end

function ninepchat.parse(self, chat_msg) 
  minetest.log("CHAT: " .. chat_msg)  

  if (not string.find(chat_msg, "→ ")) then
    return 
  end

  local words = {}
  for w in string.gmatch(chat_msg, "[^%s]+") do
    table.insert(words, w)
  end

  local user_name = words[1] 

  if (user_name == nil or user_name == "") then
    return
  end

  if (self.chat[user_name] == nil) then
      minetest.log("Add new chat user " .. user_name) 

      local ref = {
        id = self.npcf_id,
        pos = {
          x = self.pos.x + math.random(self.size.x),
          y = 0,
          z = self.pos.z + math.random(self.size.z),
        },
        yaw = 0,
				properties = {textures = {"npcf_builder_skin.png"}},
        name = "9pzone:chat_user",
        title = {text = user_name, color = "#000000"},
        --on_construct = function(self)
        --  local mv_obj = npcf.movement.getControl(self)
        --  mv_obj:look_to({ x = 13, y = 13, z = 13 })
        --  mv_obj:walk({ x = 1, y = 1, z = 1 }, 5, nil)
        --end 
      }

		  npcf:add_npc(ref)
		  npcf:add_title(ref)

      self.chat[user_name] = {
        last_time = os.time(),
        npcf_id = ref["id"]
      } 



        
      minetest.after(5, life_timer, self, user_name)

      self.npcf_id = self.npcf_id + 1 
    else
      self.chat[user_name]["last_time"] = os.time()
      minetest.log("Update last_time for " .. user_name .. " " .. tostring(os.time()))

  end
end


function ninepchatNew(ipaddr, port, pos, size) 
  return ninepchat.new(ipaddr, port, pos, size)
end

minetest.register_node("9pzone:chat", {
  drawtype = "glasslike_framed",
  tiles = { "ninepchat_terra.png" },
  inventory_image = minetest.inventorycube( "ninepchat_terra.png" ),
  paramtype = "light",
  sunlight_propagates = true, 
  groups = {cracky = 3, oddly_breakable_by_hand = 3},
})

npcf:register_npc("9pzone:chat_user" ,{
	description = "chat user",
	textures = {"npcf_builder_skin.png"},
	metadata = {
		schematic = nil,
		inventory = {},
		index = nil,
		build_pos = nil,
		building = false,
	},
	var = {
		selected = "",
		nodelist = {},
		nodedata = {},
		last_pos = {},
	},
	stepheight = 1.1,
	inventory_image = "npcf_builder_skin.png"
})
