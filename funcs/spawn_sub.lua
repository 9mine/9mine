spawn_sub = function(f, s, a, path, name)
    local p = {x = s.x, y = s.y + math.random(3, 8), z = s.z}
    local e = minetest.add_entity(p, "youtube:video")
    local le = e:get_luaentity()
    le.path = path
    le.addr = a
    le.stat = f
    if f.length < 1 then
        e:set_properties({automatic_rotate = math.pi})
        local alpha = 150
        local t = f.name .. "^[colorize:red:" .. alpha
        e:set_properties({
            textures = {t, t, t, t, t, t},
            nametag = "Generating Subs for " .. f.name
        })
        minetest.after(0.5, blink, e, f.name, alpha, a, path, name)
    else
        e:set_acceleration({x = 0, y = -9, z = 0})
        local t = f.name
        e:set_properties({textures = {t, t, t, t, t, t}, nametag = f.name})
    end

    return e
end

-- spawn_video = function(player, k)
--     local pp = player:get_pos()
--     local dir = player:get_look_dir()
--     local dst = vector.multiply(dir, 10)
--     local res = {
--         x = math.ceil(pp.x + dst.x + math.random(-9, 9)),
--         y = math.ceil(pp.y + dst.y + math.random(5, 10)),
--         z = math.ceil(pp.z + dst.z + math.random(-9, 9))
--     }
--     local alpha = 150
--     local t = k .. "^[colorize:red:" .. alpha
--     local video = minetest.add_entity(res, "youtube:video")
--     video:set_nametag_attributes({
--         color = "black",
--         text = "Generating subs . . ."
--     })
--     video:set_properties({textures = {t, t, t, t, t, t}})
--     minetest.after(0.25, blink, video, k, alpha)
-- end
