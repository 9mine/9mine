-- spawn given file at provided position ('slot') 
spawn_youtube = function(file, slot, addr, path)
    local e = nil
    local p = {x = slot.x, y = slot.y + math.random(5, 14), z = slot.z}
    local specific_entity = nil
    local text = nil
    if file.name == "ctl" then specific_entity = "youtube:search" text = "Search Video" end
    if file.name == "result" then specific_entity = "youtube:video" text = "Results" end
    e = minetest.add_entity(p, specific_entity or (file.qid.type == 128 and "control9p:dir" or
                                "control9p:file"))

    e:set_nametag_attributes({color = "black", text = text or file.name})
    e:set_armor_groups({immortal = 0})
    e:set_acceleration({x = 0, y = -9, z = 0})
    e:get_luaentity().path = path
    e:get_luaentity().addr = addr
    e:get_luaentity().stat = file
    return e
end
