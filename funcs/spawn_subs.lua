spawn_subs = function(f, s, a, path, name)
    local p = {x = s.x, y = s.y + math.random(3, 8), z = s.z}
    local e = minetest.add_entity(p, "youtube:subs")
    e:set_acceleration({x = 0, y = -9, z = 0})
    local le = e:get_luaentity()
    le.path = path
    le.addr = a
    le.stat = f
    if f.length < 1 then
        e:set_properties({automatic_rotate = math.pi})
        local alpha = 150
        local tx = f.name .. ".png" .. "^[colorize:red:" .. alpha
        e:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            nametag = "Generating Subs for " .. f.name
        })
        minetest.after(0.5, blink, e, f.name, alpha, a, path, name)
    else
        local tx = f.name .. ".png"
        e:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            nametag = "Subs Ready for " .. f.name
        })
    end

    return e
end
