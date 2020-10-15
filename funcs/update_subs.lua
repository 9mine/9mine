update_subs = function(addr, path, player_name)
    local cnx = connections[player_name][addr]
    local g = graphs[player_name]
    -- 
    local n = g:findnode(hex(addr .. path))
    local an = g:findnode(addr)

    local o_lst = n and n.listing
    local slots = n and n.slots

    local lst = name_as_key(readdir(cnx, path == "/" and "../" or path) or {})
    local prefix = path == "/" and path or path .. "/"
    local pfx = addr .. prefix

    for name, stat in pairs(lst) do
        if o_lst[name] == nil then
            local i, slot = next(slots)
            local hash = hex(pfx .. name)
            local fn = g:node(hash, {
                stat = stat,
                addr = addr,
                path = prefix .. name,
                p = slot
            })
            g:edge(n, fn)
            spawn_subs(stat, slot, addr, fn.path, player_name)
            table.remove(slots, i)
            o_lst[name] = stat
        end

        for name, stat in pairs(o_lst) do
            if lst[name] == nil then
                local hash = hex(pfx .. name)
                local fn = g:findnode(hash)
                table.insert(slots, fn.p)
                local new_p = {x = fn.p.x, y = fn.p.y + 1, z = fn.p.z}
                get_entity(fn.p):remove()
                local efn = fn:nextinput(nil)
                efn:delete()
                o_lst[name] = nil
            end
        end
    end
    minetest.after(3, update_subs, addr, path, player_name)
end
