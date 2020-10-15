spawn_sub = function(f, s, a, path)
    local p = {x = s.x, y = s.y + math.random(5, 14), z = s.z}
    local e = minetest.add_entity(p, "youtube:video")
    local le = e:get_luaentity()
    e:set_acceleration({x = 0, y = -9, z = 0})
    le.path = path
    le.addr = a
    le.stat = f
    local alpha = 150
    local t = f.name .. "^[colorize:red:" .. alpha
    e:set_properties({textures = {t, t, t, t, t, t}, nametag = f.name})
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
