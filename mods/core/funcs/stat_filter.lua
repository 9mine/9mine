stat_filter = function(stat_entity, stat)
    local texture = "core_file.png"
    if stat.qid.type == 128 then
        texture = "core_dir.png"
    end
    stat_entity:get_luaentity().stat = stat
    local lo = stat.qid.path_lo
    local hi = stat.qid.path_hi
    local qid_i64 = i64_ax(hi, lo)
    local qid = i64_toStringNo0x(qid_i64)
    stat_entity:get_luaentity().qid = qid
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

