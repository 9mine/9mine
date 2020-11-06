on_drop = function(entity, addr, origin_path, player_name, name, command)
    local lcmd = tostring(core_conf:get("lcmd"))
    local node_pos = minetest.find_node_near(entity:get_pos(), 6, {"core:plt"})
    local meta = minetest.get_meta(node_pos)
    local addr = meta:get_string("addr")
    local path = meta:get_string("path")
    local plt_node = graph:findnode(hex(addr .. path))
    path = path == "/" and path or path .. "/"
    local fullpath = path .. name
    entity:get_luaentity().path = fullpath
    cmd_write(addr, path, player_name, command .. " " .. origin_path .. " " .. fullpath, lcmd)
    if plt_node.listing[name] then 
        local file_node = graph:findnode(
            hex(addr .. path .. name))
        local pp2 = table.copy(file_node.p)
        pp2.y = pp2.y + 1
        local _, entity = pcall(get_entity, pp2)
        if entity then entity:remove()
        minetest.chat_send_player(player_name, "File replaced") end
    end
    local st = stat_read(addr, fullpath, player_name)
    plt_node.listing[name] = st
    entity:get_luaentity().stat = st
    minetest.chat_send_player(player_name, minetest.serialize(st))
end