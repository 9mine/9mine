update_subs = function(addr, path, player_name)
    local cnx = connections[player_name][addr]
    local g = graphs[player_name]
    local n = g:findnode(hex(addr .. path))
    local o_lst = n and n.listing
    local lst = name_as_key(readdir(cnx, path == "/" and "../" or path) or {})
    local prefix = path == "/" and path or path .. "/"
    local pfx = addr .. prefix
    for name, stat in pairs(o_lst) do
        if lst[name] == nil then
            local hash = hex(pfx .. name)
            local fn = g:findnode(hash)
            fn.p.y = fn.p.y + 1
            pcall(function(p) get_entity(p):remove() end, fn.p)
            local efn = fn:nextinput(nil)
            efn:delete()
            o_lst[name] = nil
        end
    end
    minetest.after(3, update_subs, addr, path, player_name)
end
