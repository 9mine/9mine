update_subs = function(a, p, pn)
    local cnx = connections[pn][a]
    local g = graphs[pn]
    -- 
    local n = g:findnode(hex(a .. p))
    local an = g:findnode(a)

    local o_lst = n and n.listing
    local slots = n and n.slots

    local lst = name_as_key(readdir(cnx, p == "/" and "../" or p) or {})
    local prefix = p == "/" and p or p .. "/"
    local pfx = a .. (p == "/" and p or p .. "/")

    for name, f in pairs(lst) do
        if o_lst[name] == nil then
            local i, s = next(slots)
            local hs = hex(pfx .. f.name)
            local fn = g:node(hs, {
                stat = f,
                addr = a,
                path = prefix .. f.name,
                p = s
            })
            g:edge(n, fn)
            spawn_sub(f, s, a, fn.path, pn)
            table.remove(slots, i)
            o_lst[name] = f
        else
            -- local fn = g:findnode(hex(pfx .. f.name))
            -- local e = get_entity(fn.p)
            -- if not e then
            --     local i, s = next(slots)
            --     spawn_sub(f, s, a, prefix .. f.name)
            --     table.remove(slots, i)
            -- end
        end

        for name, f in pairs(o_lst) do
            if lst[name] == nil then
                local hs = hex(pfx .. f.name)
                local fn = g:findnode(hs)
                table.insert(slots, fn.p)
                local new_p = {x = fn.p.x, y = fn.p.y + 1, z = fn.p.z}
                get_entity(fn.p):remove()
                local efn = fn:nextinput(nil)
                efn:delete()
                o_lst[name] = nil
            end
        end
    end
    minetest.after(5, update_subs, a, p, pn)
end
