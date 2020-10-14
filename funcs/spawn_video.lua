spawn_video = function(player, k)
    local pp = player:get_pos()
    local dir = player:get_look_dir()
    local dst = vector.multiply(dir, 20)
    local res = {
        x = math.ceil(pp.x + dst.x + math.random(-9, 9)),
        y = math.ceil(pp.y + dst.y + math.random(-5, 5)),
        z = math.ceil(pp.z + dst.z + math.random(-9, 9))
    }
    local rand_transp = 150
    local video = minetest.add_entity(res, "youtube:video")
    video:set_nametag_attributes({color = "black", text = k})
    video:set_properties({textures = {
                    k .. "^[colorize:red:" .. rand_transp, 
                    k .. "^[colorize:red:" .. rand_transp, 
                    k .. "^[colorize:red:" .. rand_transp, 
                    k .. "^[colorize:red:" .. rand_transp, 
                    k .. "^[colorize:red:" .. rand_transp, 
                    k .. "^[colorize:red:" .. rand_transp
                }})
    minetest.after(0.25, blink, video, k, rand_transp)
end