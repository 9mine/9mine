minetest.register_on_joinplayer(function(player)
    local host_info = {
        type = "tcp",
        host = "inferno",
        port = 1917,
        path = "/cmd"
    }

    print("visualizing traceroute")
    spawn_instance({x = 0, y = 0, z = 0}, 10, host_info, "localhost")

    spawn_instance({x = 0, y = 0, z = 0}, 10, host_info2, "compute1")

    spawn_instance({x = 0, y = 0, z = 0}, 10, host_info3, "compute0")

    player:set_pos({x = 0, y = 2, z = 0})

    local inventory = player.get_inventory(player)
    inventory:add_item("main", "cdmod:trace")
    inventory:add_item("main", "cdmod:connect")
    inventory:add_item("main", "cdmod:write")
end)

minetest.register_on_generated(function(minp, maxp, blockseed)
    if minp.x < 0 and minp.y < 0 and minp.z < 0 then
        create_platform({x = 0, y = 0, z = 0}, 10)
    end

end)
