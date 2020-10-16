youtube_connect_subs = function(player, formname, fields)
    local player_name = player:get_player_name()
    local g = graphs[player_name]
    local addr, path, player = connect(player, formname, fields)
    if not (addr and path and player) then return end
    local cnx = connections[player_name][addr]
    local ap = addr .. path
    if not goto_plt(ap, player) then
        local path = minetest.get_modpath("youtube") .. "/textures/thumbnails/"
        local lst = name_as_key(readdir(cnx, path == "/" and "../" or path) or
                                    {})
        for ID, _ in pairs(lst) do minetest.dynamic_add_media(path .. ID .. ".png") end
        local sz = plt.get_size(get_table_length(lst))
        if sz < 7 then sz = 7 end
        local slots, root, size = plt.create(player:get_pos(), sz, addr, path)
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
        for name, stat in pairs(lst) do
            local i, slot = next(slots)
            local fnd = g:node(hex(pfx .. name), {
                stat = stat,
                addr = addr,
                path = prefix .. name,
                p = slot
            })
            g:edge(plt, fnd)
            spawn_subs(stat, slot, addr, fnd.path, player_name)
            table.remove(slots, i)
        end
        minetest.after(2, update_subs, addr, path, player_name)
    end
end

