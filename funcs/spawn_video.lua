spawn_video = function(player, k)
    local pp = player:get_pos()
    local dir = player:get_look_dir()
    local dst = vector.multiply(dir, 10)
    local res = {
        x = math.ceil(pp.x + dst.x + math.random(-9, 9)),
        y = math.ceil(pp.y + dst.y + math.random(5, 10)),
        z = math.ceil(pp.z + dst.z + math.random(-9, 9))
    }
    local alpha = 150
    local t = k .. "^[colorize:red:" .. alpha
    local video = minetest.add_entity(res, "youtube:video")
    video:set_nametag_attributes({
        color = "black",
        text = "Generating subs . . ."
    })
    video:set_properties({textures = {t, t, t, t, t, t}})
    minetest.after(0.25, blink, video, k, alpha)
end
