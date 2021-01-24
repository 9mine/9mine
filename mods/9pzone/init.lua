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


minetest.register_on_joinplayer(function(player)
    print("register_on_joinplayer")
    player:set_pos({ x = 2, y = 2, z = 2 })
    chat:terra()

mobs:spawn({
	name = "mobs_npc:npc",
	nodes = {"9pzone:chat"},
	neighbors = {"default:grass_3"},
	min_light = 10,
	chance = 1000,
	active_object_count = 1,
	min_height = 0,
	day_toggle = false,
})

    return player
end)
