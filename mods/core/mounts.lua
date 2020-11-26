class 'mounts'

function mounts:mounts()
    self.graph = platforms:get()
end

function mounts:get_root_ns_mount()
    local root_node = platforms.root_node
    for e in root_node:walkoutputs() do
        local cmdchan = platforms:get_platform(e.head:nextoutput(nil).head.name):get_cmdchan()
        local mounts = cmdchan:execute("ns | grep '^mount'")
        if mounts and mounts ~= "" then 
            minetest.chat_send_all(mounts)
        else 
            minetest.chat_send_all("No mount points")
        end
    end
end