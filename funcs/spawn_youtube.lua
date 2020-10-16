spawn_youtube = function(file, slot, addr, path)
    local pos = table.copy(slot)
    local nametag, entity

    if file.name == "ctl" then
        nametag = "Search Video"
        pos.y = pos.y + math.random(5, 10)
        entity = minetest.add_entity(pos, "youtube:search")
        entity:set_acceleration({x = 0, y = -9, z = 0})
    end
    if file.name == "result" then
        nametag = "Results"
        pos.y = pos.y + math.random(1.1, 3.2)
        entity = minetest.add_entity(pos, "youtube:result")
    end

    lua_entity = entity:get_luaentity()
    entity:set_properties({nametag = nametag})
    lua_entity.path = path
    lua_entity.addr = addr
    lua_entity.stat = file
    return entity, pos
end
