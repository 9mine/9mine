blink = function(video, k, alpha)
    alpha = alpha == 0 and 150 or 0
    local tx = k .. "^[colorize:red:" .. alpha
    video:set_properties({textures = {tx, tx, tx, tx, tx, tx}})
    minetest.after(alpha == 0 and 0.5 or 0.25, blink, video, k, alpha)
end
