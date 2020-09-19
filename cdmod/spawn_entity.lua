spawn_entity = function(p, ip, name)
    if name == "cdmod:host" then
        local entity = minetest.add_entity(p, "cdmod:host")

        entity:set_nametag_attributes({color = "black", text = ip})
        entity:set_armor_groups({immortal = 0})
        entity:get_luaentity().ip = ip
        return entity
    end
    if name == "cdmod:packet" then
        return minetest.add_entity(p, "cdmod:packet")
    end

end