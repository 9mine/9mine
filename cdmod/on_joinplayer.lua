minetest.register_on_joinplayer(function(player)
    print("Joined from localhost")
    minetest.after(2, spawn_npc)
    player:set_pos({x = 0, y = 2, z = 0})

    -- local root = minetest.add_entity({x = 0, y = 7, z = 0}, "cdmod:directory")
    -- root:set_nametag_attributes({text = "./"})
    -- root:set_armor_groups({immortal = 0})
    -- root:get_luaentity().path = "."
    -- root:set_acceleration({x = 0, y = -6, z = 0})

    local inventory = player.get_inventory(player)
    inventory:add_item("main", "cdmod:flip")
    inventory:add_item("main", "cdmod:enter")
    inventory:add_item("main", "cdmod:connect")
    inventory:add_item("main", "cdmod:wipe")
    inventory:add_item("main", "cdmod:walk")
    inventory:add_item("main", "cdmod:createdir")

end)

minetest.register_on_generated(function(minp, maxp, blockseed)
    if minp.x < 0 and minp.y < 0 and minp.z < 0 then
        local host_info = {type = "tcp", host = "inferno", port = 31000}
        create_platform(0, 0, 0, 16, "h", nil, host_info, nil)

    end
end)

