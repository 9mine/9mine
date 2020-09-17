minetest.register_on_joinplayer(function(player)
    local host_info = {type = "tcp", host = "inferno", port = 31000}
    print("visualizing traceroute")
    local path = "./usr/inferno/traceroute.txt"
    traceroute(host_info, path)
    player:set_pos({x = 0, y = 2, z = 0})

    local inventory = player.get_inventory(player)
    inventory:add_item("main", "cdmod:flip")
    inventory:add_item("main", "cdmod:enter")
    inventory:add_item("main", "cdmod:connect")
    inventory:add_item("main", "cdmod:read")
    inventory:add_item("main", "cdmod:wipe")
    inventory:add_item("main", "cdmod:walk")
    inventory:add_item("main", "cdmod:createdir")

end)

