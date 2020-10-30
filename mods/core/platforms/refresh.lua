platform_refresh = function(plt_node, addr, path, player_name)
    local refresh_time = plt_node.settings.refresh_time
    if refresh_time ~= 0 then 
    plt.update(addr, path, player_name)
    end
    minetest.after(refresh_time == 0 and 1 or refresh_time, platform_refresh, plt_node, addr, path, player_name)
end