-- spawn given file at provided position ('slot') 
spawn_file = function(file, slot, addr, path)
    local e = nil
    local p = {x = slot.x, y = slot.y + math.random(5, 14), z = slot.z}

    e = minetest.add_entity(p, file.qid.type == 128 and "core:dir" or
                                "core:file")

    e:set_nametag_attributes({color = "black", text = file.name})
    e:set_armor_groups({immortal = 0})
    e:set_acceleration({x = 0, y = -9, z = 0})
    e:get_luaentity().path = path
    e:get_luaentity().addr = addr
    e:get_luaentity().stat = file
    return e
end
