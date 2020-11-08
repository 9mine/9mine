stat_filter = function(stat_entity, stat)
    local texture = "core_file.png"
    if stat.qid.type == 128 then
        texture = "core_dir.png"
    end
    stat_entity:get_luaentity().stat = stat
    stat_entity:get_luaentity().qid = stat.qid.path_hex
    minetest.chat_send_all(stat.qid.path_hex)
    stat_entity:set_properties({
        textures = {texture},
        nametag = stat.name
    })
    stat_entity:set_acceleration({
        x = 0,
        y = -9.81,
        z = 0
    })
end

