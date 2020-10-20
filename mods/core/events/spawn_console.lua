spawn_console = function(player, formname, fields)
    local addr, path, player = connect(player, formname, fields)
    if addr and path and player then
        local dir = player:get_look_dir()
        local dis = vector.multiply(dir, 5)
        local pp = player:get_pos()
        local fp = vector.add(pp, dis)
        fp.y = fp.y + 2
        local entity = minetest.add_entity(fp, "core:console")
        entity:set_properties({nametag = addr})
        entity:get_luaentity().addr = addr 
        entity:get_luaentity().path = path
    end
end

