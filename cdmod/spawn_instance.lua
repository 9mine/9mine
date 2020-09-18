spawn_instance = function(p, size, host_info)
    p.x = p.x + (size/2)
    p.z = p.z + (size/2)
    p.y = p.y + 7
    local entity = minetest.add_entity(p, "cdmod:binary")
    entity:set_acceleration({x = 0, y = -6, z = 0})
    entity:set_nametag_attributes(
        {color = "black", text = "traceroute"})
    entity:get_luaentity().host = host_info["host"]
    entity:get_luaentity().port = host_info["port"]
    print("IN SPAWNING " .. host_info["path"])
    entity:get_luaentity().path = host_info["path"]
end