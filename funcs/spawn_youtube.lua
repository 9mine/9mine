-- spawn given file at provided position ('slot') 
spawn_youtube = function(file, slot, addr, path)
    local tx, e, le = nil
    if file.name == "ctl" then
        e = "youtube:search"
        tx = "Search Video"
    end
    if file.name == "result" then
        e = "youtube:result"
        tx = "Results"
    end
    local p = {x = slot.x, y = slot.y + math.random(5, 14), z = slot.z}
    e = minetest.add_entity(p, e)
    le = e:get_luaentity()
    e:set_nametag_attributes({color = "black", text = tx})
    e:set_acceleration({x = 0, y = -9, z = 0})
    le.path = path
    le.addr = addr
    le.stat = file
    return e
end
