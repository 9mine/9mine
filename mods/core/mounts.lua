class 'mounts'

function mounts:set_mount_points(platform)
    local host_addr = platform.addr
    local cmdchan = platform:get_cmdchan()
    if not cmdchan then
        return
    end
    local mounts = cmdchan:execute("ns | grep '^mount'")
    if mounts and mounts ~= "" then
        local player_name = platform:get_player()
        local player_graph = graphs:get_player_graph(player_name)
        for mount in mounts:gmatch("[^\n]+") do
            local path = mount:match("/.+")
            if path then
                local platform = player_graph:get_platform(host_addr .. path)
                if platform and not platform.mount_point then
                    platform.mount_point = path
                    minetest.chat_send_player(player_name,
                        "For platform " .. host_addr .. path .. " set mount_point " .. path)
                end
            end
        end
    end
end
