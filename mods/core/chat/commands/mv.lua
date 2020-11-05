mv = function(player_name, params)
    local lcmd = tostring(core_conf:get("lcmd"))
    local addr, path = plt_by_name(player_name)
    local sources, destination, _ = parse_mvcp_params(params, path)

    get_sources(sources, addr)
    get_destination(destination, addr)
    cmd_write(addr, path, player_name, "mv " .. params, lcmd)
    local changes, changes_path = get_changes(destination, addr, player_name)
    if changes then graph_changes(changes, changes_path, addr) end
    local result, response = pcall(map_changes_to_sources, sources, changes, addr)
    if not result then send_warning(player_name, response) end

end

minetest.register_chatcommand("mv", {func = mv})
