spawn_subs = function(stat, slot, addr, path, player_name)
    local pos = table.copy(slot)
    pos.y = pos.y + math.random(3, 8)
    local entity = minetest.add_entity(pos, "youtube:subs")
    local lua_entity = entity:get_luaentity()
    lua_entity.path = path
    lua_entity.addr = addr
    lua_entity.stat = stat
    local name = stat.name
    if stat.length < 1 then
        entity:set_properties({automatic_rotate = math.pi})
        local alpha = 150
        local tx = name .. ".png" .. "^[colorize:red:" .. alpha
        entity:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            nametag = "Generating Subs for " .. name
        })
        minetest.after(0.5, blink, entity, name, alpha, addr, path, player_name)
    else
        local tx = name .. ".png"
        entity:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            nametag = "Subs Ready for " .. name
        })
    end

    return entity
end
