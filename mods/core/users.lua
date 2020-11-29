minetest.register_on_prejoinplayer(function(name, ip)
    -- get string in form of tcp!host!port from ENV or mod.conf
    local attach_string = os.getenv("INFERNO_ADDRESS") ~= "" and os.getenv("INFERNO_ADDRESS") or
                              core_conf:get("inferno_address")

    -- establish 9p attachment
    local conn = connections[attach_string]
    if not conn then
        conn = connection(attach_string)
        if not conn:attach() then
            return "Failed connecting to the inferno os"
        end
    elseif conn:is_alive() then
        print("Already attached. Connection is alive")
    elseif conn.tcp then
        print("Connection is not alive. Reconnecting")
        conn:reattach()
    else
        if not conn:attach() then
            return "Failed connecting to the inferno os"
        end
    end

    -- check for presence of cmdchan
    local cmdchan_path = tostring(core_conf:get("cmdchan_path"))
    local root_cmdchan = cmdchan(conn, cmdchan_path)
    if not root_cmdchan:is_present() then
        return "cmdchan at path " .. cmdchan_path .. " is not available"
    else
        print("cmdchan is available")
    end

    -- mount registry
    root_cmdchan:execute("mount -A tcp!registry.dev.metacoma.io!30100 /mnt/registry")
    os.execute("sleep 2")
    -- get and mount user management service
    local user_management = root_cmdchan:execute("ndb/regquery -n description 'user management'")
    root_cmdchan:execute("mount -A tcp!user.dev.metacoma.io!30101 /n/9mine")
end)

