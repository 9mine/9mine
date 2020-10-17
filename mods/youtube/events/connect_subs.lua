youtube_connect_subs = function(player, formname, fields)
    local player_name = player:get_player_name()
    local g = graphs[player_name]

    local addr, path, player = connect(player, formname, fields)

    if not (addr and path and player) then return end

    local cnx = connections[player_name][addr]
    local ap = addr .. path

    if not goto_plt(ap, player) then
        local lst = name_as_key(readdir(cnx, path == "/" and "../" or path) or
                                    {})

        minetest.chat_send_player(player_name,
                                  "\nDownloading missing textures . . . \n")
        for ID, _ in pairs(lst) do
            save_thumb(ID)
            minetest.chat_send_player(player_name,
                                      "Texture ID " .. ID .. " downloaded.\n")
        end
        minetest.chat_send_player(player_name, "\nAll textures downloaded\n")

        local size = plt.get_size(get_table_length(lst))
        local slots, root, size = plt.create(player:get_pos(), size, addr, path)
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
        g:edge(g:findnode(addr), plt, addr .. "->" .. path)

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
            g:edge(plt, fnd, plt.path .. "->" .. name)
            spawn_subs(stat, slot, addr, fnd.path, player_name)
            table.remove(slots, i)
        end
        minetest.after(2, update_subs, addr, path, player_name)
    end
end

