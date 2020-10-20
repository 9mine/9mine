copy_entity = function(file, path, stat)
    local p = file:get_pos()
    local e = minetest.add_entity(p,
                                  file:get_luaentity().stat.qid.type == 128 and
                                      "control9p:dir" or "control9p:file")
    e:set_nametag_attributes({color = "black", text = stat.name})
    e:set_armor_groups({immortal = 0})
    e:set_acceleration({x = 0, y = -9, z = 0})
    e:get_luaentity().path = path
    e:get_luaentity().addr = file:get_luaentity().addr
    e:get_luaentity().stat = stat

    return e
end
