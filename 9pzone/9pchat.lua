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
  self.lifetime = 1800

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

  return self
end

function ninepchat.getPos(self)
  return self.pos
end
function ninepchat.getSize(self)
  return self.size
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
      end
    end
  end

  for x = self.pos.x, self.pos.x + self.size.x - 1 do
    minetest.add_node(
      { x = x, y = self.pos.y + 1, z = self.pos.z }, { name = "9pzone:chat" }
    ) 
    minetest.add_node(
      { x = x, y = self.pos.y + 2, z = self.pos.z }, { name = "9pzone:chat" }
    ) 
  end

  for x = self.pos.x, self.pos.x + self.size.x - 1 do
    minetest.add_node(
      { x = x, y = self.pos.y + 1, z = self.pos.z + self.size.z - 1 }, { name = "9pzone:chat" }
    ) 
    minetest.add_node(
      { x = x, y = self.pos.y + 2, z = self.pos.z + self.size.z - 1 }, { name = "9pzone:chat" }
    ) 
  end

  for z = self.pos.z, self.pos.z + self.size.z - 1 do
    minetest.add_node(
      { x = self.pos.x, y = self.pos.y + 1, z = z }, { name = "9pzone:chat" }
    ) 
    minetest.add_node(
      { x = self.pos.x, y = self.pos.y + 2, z = z }, { name = "9pzone:chat" }
    ) 
  end

  for z = self.pos.z, self.pos.z + self.size.z - 1 do
    minetest.add_node(
      { x = self.pos.x + self.size.x - 1, y = self.pos.y + 1, z = z }, { name = "9pzone:chat" }
    ) 
    minetest.add_node(
      { x = self.pos.x + self.size.x - 1, y = self.pos.y + 2, z = z }, { name = "9pzone:chat" }
    ) 
  end

end

function life_timer(chat, user_name) 
  local last_time = chat.chat[user_name]["last_time"]  

  local obj  = chat.chat[user_name]['obj'] 

  if (os.time() - last_time < chat.lifetime) then
    minetest.log(user_name .. " are still life ")
    minetest.after(5, life_timer, chat, user_name)
    return
  end

  minetest.log("----")
  pprint(chat.chat[user_name])
  minetest.log("----")
  minetest.log("Removed " .. user_name .. " by timer " .. tostring(last_time))
  obj:remove() 
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

        
      local user_pos = {
        x = (self.pos.x + 2) + math.random(self.size.x - 4),
        y = 2,
        z = (self.pos.z + 2) + math.random(self.size.z - 4) 
      }

      --local mobs = { "folk10", "folk11", "folk12", "folk13", "folk14", "folk15", "folk15", "folk16", "folk17", "folk18", "folk19", "folk20", "folk21" }
      local mob_id = mobs[math.random(#mobs)]

  
      local obj = minetest.add_entity(user_pos, "9pzone:" .. mob_id)
      obj:set_properties({ nametag = user_name, color = "black" })
      self.chat[user_name] = {
        last_time = os.time(), 
        obj = obj 
      }

      minetest.log(dump(obj:get_luaentity())) 
      minetest.after(5, life_timer, self, user_name)
      

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
  diggable = false,
  climbable = false,
  pointable = false,
  is_ground_content = false,
  paramtype = "light",
  sunlight_propagates = true, 
  groups = {cracky = 3, oddly_breakable_by_hand = 3, immortal = 1 },
})

mobs = {} 

for i=1,22 do
  aliveai.create_bot({
    description="Regular npc" .. i,
    name="folk" .. i,
		name_color="black",
    texture="aliveai_folk" .. i .. ".png",
    talking = 0,
    building = 0,
    dmg = 0,
    crafting = 0,
    fighting  = 0,
    drowning = 0,
    attacking = 0,
    mine = 0,
    minening = 0,
  })
  mobs[i] = "folk" .. i
end
