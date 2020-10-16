generate_subs = function(entity, player)
    local player_pos = player:get_pos()
    local entity_pos = entity:get_pos()
    local player_name = player:get_player_name()
    local ID = entity:get_luaentity().id
    local plt_node = minetest.find_node_near(entity_pos, 1, "control9p:plt",
                                             true)
    if not plt_node then
        add_video_item(ID, player)
        entity:remove()
        send_warning(player_name, "No speech2text proccessing unit found")
        return
    end

    local plt_node_meta = minetest.get_meta(plt_node)
    local addr = plt_node_meta:get_string("addr")
    local path = plt_node_meta:get_string("path")
    local cnx = connections[player_name][addr]

    local result, response = pcall(file_create, addr, path, player_name, ID)
    if (not result) and response:match("File exists") then
        entity:remove()
        add_video_item(ID, player)
        send_warning(player_name, "Subs for " .. ID ..
                         " exists. Video set back to inventory")
        return
    end
 
    local prefix = path == "/" and path or path .. "/"
    local pfx = addr .. prefix
    local result, stat = pcall(stat_read, addr, prefix .. ID, player_name)
    if not result then
        entity:remove()
        add_video_item(ID, player)
        send_warning(player_name, stat)
        return
    end

    local graph = graphs[player_name]
    local subs_gnode = graph:findnode(hex(addr .. path))
    local file_gnode = graph:node(hex(pfx .. ID), {
        stat = stat,
        addr = addr,
        path = prefix .. ID,
        p = plt_node
    })

    graph:edge(subs_gnode, file_gnode)
    subs_gnode.listing[ID] = stat
    if stat.length == 0 then
        entity:get_luaentity().addr = addr
        entity:get_luaentity().path = file_gnode.path
        entity:set_properties({automatic_rotate = math.pi})
        local alpha = 150
        local tx = ID .. ".png" .. "^[colorize:red:" .. alpha
        entity:set_properties({
            textures = {tx, tx, tx, tx, tx, tx},
            nametag = "Generating Subs for " .. ID
        })
        minetest.after(0.5, blink, entity, ID, alpha, addr, file_gnode.path,
                       player_name)
    end
end
