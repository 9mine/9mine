minetest.register_on_joinplayer(function(player)
    local host_info = {type = "tcp", host = "inferno", port = 31000}
    print("visualizing traceroute")
    local path = "./usr/inferno/traceroute.txt"
    traceroute(host_info, path, player, {})
    player:set_pos({x = 0, y = 0, z = 0})

    local inventory = player.get_inventory(player)
    inventory:add_item("main", "cdmod:trace")
    inventory:add_item("main", "cdmod:connect")

end)

