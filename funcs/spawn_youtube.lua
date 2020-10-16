spawn_youtube = function(file, slot, addr, path)
    local tx, e, le, p = nil
    if file.name == "ctl" then
        e = "youtube:search"
        tx = "Search Video"
        p = {x = slot.x, y = slot.y + math.random(5, 14), z = slot.z}
        e = minetest.add_entity(p, e)
        e:set_acceleration({x = 0, y = -9, z = 0})
    end
    if file.name == "result" then
        e = "youtube:result"
        tx = "Results"
        p = {x = slot.x, y = slot.y + math.random(3), z = slot.z}
        e = minetest.add_entity(p, e)
    end

    le = e:get_luaentity()
    e:set_nametag_attributes({color = "black", text = tx})
    le.path = path
    le.addr = addr
    le.stat = file
    return e, p
end
