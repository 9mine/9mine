blink = function(subs, texture, alpha, addr, path, player_name)
    local st = stat_read(addr, path, player_name)
    if st.length > 0 then
        subs:set_properties({
            textures = {texture, texture, texture, texture, texture, texture},
            automatic_rotate = 0,
            nametag = "Subs For " .. st.name
        })
        subs:set_acceleration({x = 0, y = -9, z = 0})
    else
        alpha = alpha == 0 and 150 or 0
        local tx = texture .. "^[colorize:red:" .. alpha
        subs:set_properties({textures = {tx, tx, tx, tx, tx, tx}})
        minetest.after(alpha == 0 and 0.5 or 0.25, blink, subs, texture, alpha,
                       addr, path, player_name)
    end
end
