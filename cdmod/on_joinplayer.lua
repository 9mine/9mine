minetest.register_on_joinplayer(function(player)
    local host_info = {
        type = "tcp",
        host = "inferno",
        port = 31000,
        path = "/usr/inferno/traceroute.txt"
    }
    local host_info2 = {
        type = "tcp",
        host = "inferno2",
        port = 32000,
        path = "usr/inferno/traceroute.txt"
    }
    print("visualizing traceroute")
    spawn_instance({x = 0, y = 0, z = 0}, 10, host_info)

    create_platform({x = -10, y = 0, z = -10}, 5)

    spawn_instance({x = -10, y = 0, z = -10}, 5, host_info2)
    player:set_pos({x = 0, y = 2, z = 0})

    local inventory = player.get_inventory(player)
    inventory:add_item("main", "cdmod:trace")
    inventory:add_item("main", "cdmod:connect")

end)

minetest.register_on_generated(function(minp, maxp, blockseed)
    if minp.x < 0 and minp.y < 0 and minp.z < 0 then
        create_platform({x = 0, y = 0, z = 4}, 10)
    end
    if minp.x < -10 or minp.y < -10 or minp.z < 0 then
        create_platform({x = -10, y = 0, z = -10}, 5)
    end

end)
