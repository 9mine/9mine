class 'mounts'

function mounts:mounts()
    self.graph = platforms:get()
end

function mounts:set_mount_points()
    local root_node = platforms.root_node
    for e in root_node:walkoutputs() do
        local host_addr = e.head.name
        local cmdchan = platforms:get_platform(e.head:nextoutput(nil).head.name):get_cmdchan()
        local mounts = cmdchan:execute("ns | grep '^mount'")
        if mounts and mounts ~= "" then
            for mount in mounts:gmatch("[^\n]+") do
                local path = mount:match("/.+")
                local platform = platforms:get_platform(host_addr .. path)
                if platform and not platform.mount_point then 
                    platform.mount_point = path
                    minetest.chat_send_all("For platform " .. host_addr .. path .. " set mount_point " .. path)
                end

            end
            minetest.chat_send_all(mounts)
        else
            minetest.chat_send_all("No mount points")
        end
    end
end
