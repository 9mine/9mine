function get_diff(old_listing, new_listing, path)
    local old = table.copy(old_listing)
    local diff = {}
    for file_name, stat in pairs(new_listing) do
        if old[file_name] == nil then
            diff[file_name] = {stat = stat, path = path}
        else
            if not ((stat.qid.path_lo == old[file_name].qid.path_lo) and
                (stat.qid.path_hi == old[file_name].qid.path_hi) and
                stat.qid.version == old[file_name].qid.version) then
                diff[file_name] = {stat = stat, path = path}
            end
            old[stat] = nil
        end
    end
    if get_table_length(diff) == 0 then
        return nil
    else
        return diff
    end
end
