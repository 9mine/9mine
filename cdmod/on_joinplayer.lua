minetest.register_on_joinplayer(function(player)
    parted = false
    local count = 0
    local spawned = {}
    for k, v in pairs(npcf.npcs) do
        spawned[v.title.text] = count
        count = count + 1
    end
    spawn_npc(spawned, count, player)

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

minetest.register_on_leaveplayer(function(ObjectRef, timed_out)
    ObjectRef = nil
    parted = true
end)

minetest.register_on_generated(function(minp, maxp, blockseed)
    if minp.x < 0 and minp.y < 0 and minp.z < 0 then
        local host_info = {type = "tcp", host = "inferno", port = 31000}
        create_platform(0, 0, 0, 16, "h", nil, host_info, nil)

    end
end)

