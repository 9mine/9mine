blink = function(entity, ID, alpha, addr, path, player_name)
    local result, st = pcall(stat_read, addr, path, player_name)
    if not result then
        entity:set_properties({nametag = "Error. Deleting . . ."})
        return
    end
    if st.length > 0 then
        local tx = ID .. ".png"
        entity:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            automatic_rotate = 0,
            nametag = "Subs Ready For " .. st.name
        })
    else
        alpha = alpha == 0 and 150 or 0
        local tx = ID .. ".png^[colorize:red:" .. alpha
        entity:set_properties({textures = {tx, tx, tx, tx, tx, tx}})
        minetest.after(alpha == 0 and 0.5 or 0.25, blink, entity, ID, alpha,
                       addr, path, player_name)
    end
end
