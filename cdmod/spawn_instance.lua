spawn_instance = function(p, size, host_info, text)
    if text == nil then
        text = "traceroute"
    end
    p.x = math.random(p.x, p.x + (size - 1))
    p.z = math.random(p.z, p.z + (size - 1))
    p.y = p.y + 7
    local entity = minetest.add_entity(p, "cdmod:binary")
    entity:set_acceleration({x = 0, y = -9.81, z = 0})
    entity:set_nametag_attributes({color = "black", text = text})
    entity:get_luaentity().host = host_info["host"]
    entity:get_luaentity().port = host_info["port"]
    entity:get_luaentity().path = host_info["path"]
end
