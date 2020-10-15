youtube_connect_subs = function(player, formname, fields)
    local name = player:get_player_name()
    local g = graphs[name]
    local addr, path, player = connect(player, formname, fields)
    local cnx = connections[name][addr]
    local ap = addr .. path
    if not (addr and path and player) then return end

    if not goto_plt(ap, player) then
        -- get listing
        local lst = name_as_key(readdir(cnx, path == "/" and "../" or path) or
                                    {})
        -- create platform
        local sz = plt.get_size(get_table_length(lst))
        local slots, root, size = plt.create(player:get_pos(), sz, addr, path)
        print("CHECKPOINT 1")
        to_plt(player, root)
        local plt = g:node(hex(ap), {
            plt = true,
            listing = lst,
            addr = addr,
            slots = slots,
            root = root,
            size = size,
            path = path,
            addr_path = ap
        })
        g:edge(g:findnode(addr), plt)

        local prefix = path == "/" and path or path .. "/"
        local pfx = addr .. prefix
        print("CHECKPOINT 2")

        for _, f in pairs(lst) do
            local i, s = next(slots)
            local hs = hex(pfx .. f.name)
            local fnd = g:node(hs, {
                stat = f,
                addr = addr,
                path = prefix .. f.name,
                p = s
            })
            graph:edge(plt, fnd)
            print("CHECKPOINT 3")

            spawn_sub(f, s, addr, fnd.path)
            print("CHECKPOINT 5")

            table.remove(slots, i)
        end
        minetest.after(5, update_subs, addr, path, name)
    end

end

