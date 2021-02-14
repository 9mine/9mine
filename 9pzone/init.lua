local modpath = minetest.get_modpath("9pzone")
dofile(modpath .. "/9pchat.lua")

print("9p.zone module")

local chat = ninepchatNew("172.24.172.227", 7777, 
  {
    x = 0,
    y = 0,
    z = 0,
  },
  {
    x = 20,
    y = 1,
    z = 20,
  }
)


minetest.register_on_generated(function(minp, maxp, seed)
  local pos = chat:getPos()
  local size = chat:getSize() 

  if (minp.x >= pos.x and minp.y >= pos.y and minp.z >= pos.z and pos.x + size.x <= maxp.x and pos.y + size.y <= maxp.y and pos.z + size.z <= maxp.z) then
	  local debug = "minp="..(minetest.pos_to_string(minp))..", maxp="..(minetest.pos_to_string(maxp))..", seed="..seed
	  print(debug)
	  minetest.chat_send_all(debug)
    chat:terra() 
  end
end)


minetest.register_on_joinplayer(function(player)
    print("register_on_joinplayer")
    player:set_pos({ x = 2, y = 2, z = 2 })
    local inv = player:get_inventory() 
    --inv:add_item("main", "aliveai_trader:trader") 
    inv:add_item("main", "aliveai:terminal") 
    return player
end)

minetest.register_chatcommand("bot", {
	params = "",
	description = "Test 1: Modify player's inventory view",
	func = function(name, param)
    minetest.add_entity({ x = 5, y = 2, z = 5 }, "aliveai_trader:trader" ) 
    minetest.add_entity({ x = 5, y = 2, z = 5 }, "aliveai_trader:worker" ) 
    --minetest.chat_send_all("minetest mod " .. minetest.get_current_modname()) 
  end,

  --[[
	func = function(name, param)
      local size = chat:getSize() 
      local pos = chat:getPos() 

      local ref = {
        id = 3,
        pos = {
          x = pos.x + math.random(size.x),
          y = pos.y + 1,
          z = pos.z + math.random(size.z),
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
		
	end,
  ]]--
})


