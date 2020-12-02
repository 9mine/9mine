class 'mounts'

function mounts:set_mount_points(platform)
    local host_addr = platform.addr
    local cmdchan = platform:get_cmdchan()
    if not cmdchan then
        return
    end
    local mounts = cmdchan:execute("ns | grep '^mount'")
    if mounts and mounts ~= "" then
        for mount in mounts:gmatch("[^\n]+") do
            local path = mount:match("/.+")
            if path then
                local platform = platforms:get_platform(host_addr .. path)
                if platform and not platform.mount_point then
                    platform.mount_point = path
                    minetest.chat_send_all("For platform " .. host_addr .. path .. " set mount_point " .. path)
                end
            end
        end
    end
end
