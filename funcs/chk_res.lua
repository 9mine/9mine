chk_res = function(name, node, req)
    local a = node.addr
    local rp = node.result_path
    local st = stat_read(a, rp, name)

    if st.length > 0 then
        local content = file_read(a, rp, name)
        local i, s = next(node.slots)
        local p = {x = s.x, y = s.y + 1, z = s.z}
        local pl = minetest.get_player_by_name(name)
        local res, nwp = spawn_youtube(st, p, a, rp)

        nwp.y = nwp.y - 1.5
        local d = vector.direction(pl:get_pos(), nwp)
        pl:set_look_vertical(-math.atan2(d.y, math.sqrt(d.x * d.x + d.z * d.z)))
        pl:set_look_horizontal(-math.atan2(d.x, d.z))

        table.remove(node.slots, i)
        local ss = req:get_luaentity().search_string
        res:get_luaentity().content = content
        res:get_luaentity().req = ss
        res:set_nametag_attributes({text = "Query: " .. ss})
        res:set_acceleration(vector.new())
        req:set_nametag_attributes({text = "Search Video"})
    else
        req:set_pos(node.ctl_p)
        req:set_acceleration({x = 0, y = -4, z = 0})
        req:set_velocity({x = 0, y = 2, z = 0})
        minetest.after(0.5, chk_res, name, node, req)
    end
end
