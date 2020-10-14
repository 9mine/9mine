blink = function(video, k, rand_transp)
    if rand_transp == 0 then
        rand_transp = 150
    else
        rand_transp = 0
    end
    video:set_properties({
        textures = {
            k .. "^[colorize:red:" .. rand_transp,
            k .. "^[colorize:red:" .. rand_transp,
            k .. "^[colorize:red:" .. rand_transp,
            k .. "^[colorize:red:" .. rand_transp,
            k .. "^[colorize:red:" .. rand_transp,
            k .. "^[colorize:red:" .. rand_transp
        }
    })
    minetest.after(rand_transp == 0 and 0.5 or 0.25, blink, video, k, rand_transp)
end
