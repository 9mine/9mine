chk_res = function(name, node, req)
    local a = node.addr
    local rp = node.result_path
    local st = stat_read(a, rp, name)

    if st.length > 0 then
        local content = file_read(a, rp, name)
        local res = spawn_youtube(st, node.result_p, a, rp)

        res:get_luaentity().content = content

        res:set_nametag_attributes({
            text = "Queary: " .. req:get_luaentity().search_string
        })

        req:set_nametag_attributes({text = "Search Video"})
    else
        req:set_pos(node.ctl_p)
        req:set_acceleration({x = 0, y = -4, z = 0})
        req:set_velocity({x = 0, y = 2, z = 0})
        minetest.after(0.5, chk_res, name, node, req)
    end
end
