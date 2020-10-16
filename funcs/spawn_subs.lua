spawn_subs = function(stat, slot, addr, path, player_name)
    local p = {x = slot.x, y = slot.y + math.random(3, 8), z = slot.z}
    local entity = minetest.add_entity(p, "youtube:subs")
    entity:set_acceleration({x = 0, y = -9, z = 0})
    local lua_entity = entity:get_luaentity()
    lua_entity.path = path
    lua_entity.addr = addr
    lua_entity.stat = stat
    if stat.length < 1 then
        entity:set_properties({automatic_rotate = math.pi})
        local alpha = 150
        local tx = stat.name .. ".png" .. "^[colorize:red:" .. alpha
        entity:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            nametag = "Generating Subs for " .. stat.name
        })
        minetest.after(0.5, blink, entity, stat.name, alpha, addr, path,
                       player_name)
    else
        local tx = stat.name .. ".png"
        entity:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            nametag = "Subs Ready for " .. stat.name
        })
    end

    return entity
end
