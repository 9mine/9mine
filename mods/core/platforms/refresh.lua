platform_refresh = function(plt_node, addr, path, player_name)
    local refresh_time = plt_node.settings.refresh_time
    if refresh_time == 0 then
        return
    end
    plt.update(addr, path, player_name)
    minetest.after(refresh_time, platform_refresh, plt_node, addr, path, player_name)
end