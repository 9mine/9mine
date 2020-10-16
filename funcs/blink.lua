blink = function(entity, ID, alpha, addr, path, player_name)
    local result, st = pcall(stat_read, addr, path, player_name)
    if not result then
        entity:set_properties({nametag = "Error. Deleting . . ."})
        -- local graph = graphs[player_name]
        -- local subs_gnode = graph:findnode(hex(addr .. path))
        -- local edge_subs = subs_gnode:nextinput(nil)
        -- local lst = edge_subs.tail.listing
        -- edge_subs:delete()
        -- lst[ID] = nil
        -- entity:remove()
        return
    end
    if st.length > 0 then
        local tx = ID .. ".png"
        entity:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            automatic_rotate = 0,
            nametag = "Subs For " .. st.name
        })
    else
        alpha = alpha == 0 and 150 or 0
        local tx = ID .. ".png^[colorize:red:" .. alpha
        entity:set_properties({textures = {tx, tx, tx, tx, tx, tx}})
        minetest.after(alpha == 0 and 0.5 or 0.25, blink, entity, ID, alpha,
                       addr, path, player_name)
    end
end
